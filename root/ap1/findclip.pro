;+
; NAME:
;  FINDCLIP
;
; DESCRIPTION:
;  This function estimates how to scale a first moment map of a data
;  cube such that regions of interest will show a maximal velocity
;  range. The idea is to calculate lower and upper bounds to the
;  velocities in the first moment map. Pixels outside these boundaries
;  should be set to these boundaries, effectively compressing the range of
;  values to display on a screen. This is accomplished by finding whch
;  range of velocities cover a set of pixels in a first moment map
;  whose values in the zeroth moment map occupy most of the total flux
;  in that map. This is meant to mimic what the IDL astronomy routine
;  SIGRANGE does for a single image.
;
; CALLING SEQUENCE:
;  result=FINDCLIP(inmom0, inmom1, [FRACTION=fraction, MISSING=MISSING)
;
; INPUTS:
;  inmom0: A 2d image giving the zeroth moment of some data cube
;  inmom1: A 2d image giving the first moment of the same data cube
;
; KEYWORD PARAMETERS:
;  FRACTION: Set this keyword to be what fraction of the mom0 map flux
;            is contained within pixels which fall inbetween the output
;            velocity boundaries in the mom1 map. If not set, 0.9 is used.
;  MISSING: Ignore pixels in the zeroth moment map that have this value
;
; OUTPUT:
;  A 2 element vector giving two velocities. The pixels falling
;  between the range of these two values in inmom1 have values in
;  inmom0 which together comprise 0.9 (or FRACTION) of the total flux
;  in inmom0.
;
; NOTES:
;  If the zeroth moment array contains negative values, these pixels
;  are ignored in the calculation.
;
;  If the arrays have more than 10,000 valid points, the calculation
;  is based on a random sample of 10,000 points for speed.
; 
; MODIFICATION HISTORY:
;  August 13, 2008: Written by Chris Beaumont
;  AUGUST 15, 2008: Changed NOZERO keyword to MISSING to mimic sigrange.
;-

function findclip, mom0, mom1, fraction=fraction, missing=missing
;-check inputs

if n_params() lt 2 then begin
    print,''
    print,'FINDCLIP Calling Sequence:'
    print,' result=findclip(mom0,mom1,[fraction=fraction,/nozero])
    print,' mom0,mom1: 0 and 1st moment maps of a data cube'
    print,' fraction: The fraction of the flux in mom0 to represent'
    print,' nozero: Treat zeros as missing data'
    print,''
    return,0
endif
if ~keyword_set(fraction) then fraction=0.9

;-select finite, nonnegative pixels

safe_mom0=mom0[where(mom0 ge 0)]
safe_mom1=mom1[where(mom0 ge 0)]

;-filter out pixels with value MISSING
if n_elements(MISSING) eq 1 then begin
    safe_mom0=safe_mom0[where((safe_mom0-missing)^2 le 1d-5)]
    safe_mom1=safe_mom1[where((safe_mom0-missing)^2 le 1d-5)]
endif

;-if there are more than 10,000 elements in these arrays, randomly
;sample 10,000 elements for speed
if n_elements(safe_mom0) gt 10000 then begin
    indices=randomu(seed,10000)*n_elements(safe_mom0)
    safe_mom0=safe_mom0[indices]
    safe_mom1=safe_mom1[indices]
endif

m1min=min(safe_mom1)
m1max=max(safe_mom1)
temp_mom1=safe_mom1
delta=0

;-create a histogram of scaled safe_mom1 values. Use these values to make a
;-cumulative distribution funtion cdf such that cdf(x)=fraction of flux
;-in safe_mom0 contained in pixels which have values less than X in safe_mom1 

nbins=1024
find_range:

last_delta=delta
x=m1min+findgen(nbins)*(m1max-m1min)/(nbins-1)
h=histogram((temp_mom1-m1min)/(m1max-m1min)*nbins,reverse_indices=ri)

;-make a cumulative distribution function of safe_mom0

cdf=fltarr(nbins)
for i=0L, nbins-2, 1 do if ri[i+1] gt ri[i] then $
  cdf[i+1:nbins-1]+=total(safe_mom0[ri[ri[i]:ri[i+1]-1]])
cdf/=total(safe_mom0)

;-find the upper and lower edges of the distribution
imin=max(where(cdf le (1-fraction)/2.))
imax=min(where(cdf ge (1+fraction)/2.))
if imax eq -1 then imax=nbins-1


;-if truncation boundaries are the same value, use a few channels

if imax eq imin then begin
    range=m1max-m1min
    m1max=x[imax+1]
    m1min=x[imax-1]
endif

;-if the range has changed drastically (as it would if imax eq imin,
;-repeat with a finer resolution

temp_mom1=m1min > safe_mom1 < m1max
delta = m1max-m1min
if abs((delta-last_delta)/(delta+last_delta)) ge .05 then goto,find_range
   
;-return answer
;pdf=cdf-shift(cdf,1)
;pdf[0]=0
;plot,convolve(pdf,[0,1,2,3,4,5,6,5,4,3,2,1,0])
;stop
return,[x[imin],x[imax]]
end
