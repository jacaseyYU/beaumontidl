;+
; NAME:
;  PEAKPICK
;
; PURPOSE:
;  This is a satisfyingly named function to attempt to automatically
;  determine the center and width of the strongest line in a spectrum.
;
; CALLING SEQUENCE:
;  result=PEAKPICK( [X] , Y )
;
; INPUTS:
;  Y: A vector of intensity values for points along a spectrum
;
; OPTIONAL INPUTS:
;  X: A vector of velocity/frequency/wavelength values for each point
;  in Y. If included, the output will be in the units
;  that X uses.  
;
; OUTPUT:
;  The two element vector [line center, line standard deviation]
;
; RESTRICTIONS:
;  The current algorithm looks in the vicinity of the maximum y value
;  for the line center. Thus, it will not perform well with noisy or
;  weak spectra. Also, another line within roughly 4 linewidths of the
;  main line will skew the output.
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, June 2008.
;  July 15 2008: Fixed bug in average calculation which led to out of
;  bounds indexing. Chris Beaumont.
;-

function peakpick, xin, yin

;on_error, 1

if n_params() eq 2 then begin
    x=xin
    y=yin
endif else if n_params() eq 1 then begin
    y=xin
    x=findgen(n_elements(yin))
endif else begin
    message,'CALLING SEQUENCE: result=peakpick(xin, yin)'
endelse

;find rough peak
peak=where(y eq max(y))
peak=peak[0]

;find rough FWHM
i=peak
max=y[peak]
go=1
while go do begin
    i+=5
    if (y[i]/max le .5) then go=0
endwhile
i-=peak


;calculate mean, sigma
lo=peak-4*i>0
hi=peak+4*i<n_elements(x)-1
mean=total((x*y)[lo:hi])/total(y[lo:hi])
meanind=where(abs(x-mean) eq min(abs(x-mean)))
meanind=meanind[0]
;calculate sigma
x-=mean
lo=meanind-3*i>0
hi=meanind+3*i<n_elements(x)-1
sigma=sqrt(total(x[lo:hi]^2*y[lo:hi])/total(y[lo:hi]))
return,[mean,sigma]

end
