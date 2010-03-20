pro avmap, avcat, fwhm, header, map, auto=auto, sigma=sigma, verbose=verbose, varmap=varmap
;+
; NAME:
;  AVMAP
;
; DESCRIPTION:
;  This procecure creates a spatialy smoothed AV map from a list of measured positions
;  and AVs. From Lombardi and Alves 2001. It returns the AV map, with
;  a minimal FITS header describing the region. The size, scale, and
;  position of the map can be set manually or autmatically. The
;  routine also implements the sigma clipping technique described in
;  section 3.2.2 of Lombardi and Alves. The technique uses a gaussian
;  smoothing kernel
;
; CALLING SEQUENCE:
;  avmap, avcat, fwhm, header, map, [/AUTO, SIGMA=sigma]
;
; INPUTS:
;  AVCAT: A 4-by-n array. Each row lists (x position, y position,
;  AV, AV error). x and y positions must be in decimal form.
;
;  FWHM: The FWHM of the gaussian smoothing kernel. Given in the same
;  units as x and y from AVCAT.
;
; OPTIONAL INPUTS:
;  HEADER: A string array (created, for example, using sxaddpar)
;  containing a FITS header. This header will be used to set the
;  position, size, and scale of the output image. Alternatively, to
;  automatically set these parameters using information in AVCAT,
;  supply a dummy variable for HEADER and set the keyword AUTO.
;
; OUTPUTS:
;  HEADER: A string array containing the FITS header associated with
;  the output AV map. If HEADER was supplied on input, it is unmodified.
;
;  MAP: The spatially smoothed AV map. 
;
; OPTIONAL KEYWORDS:
;  AUTO: If set, the size, scale, and position of the output map will
;  be determined from the coordinates in AVCAT. The map will be
;  just wide enough to contain each point in avcat, with a pixel scale
;  of fwhm/10.
;
;  SIGMA: If set, the avmap will be iteratively sigma-clipped until it
;  converges on a solution. The value of the SIGMA keyword is the
;  clipping standard deviation value (eg, the map is only calculated
;  for those points in AVMAP for which |AV- average(avmap)| < = SIGMA
;                                           * stdev(avmap)
;
;  VERBOSE: If set, print information during iteration
;
;  VARMAP: Set to a named variable which will contain the variance
;  estimates of the AV map
;
; RESTRICTIONS:
;  --The output map is the cartesian projection of the x-y coordinates.
;  --Only gaussian smoothing kernels are allowed.
;  --If an input header is provided, it must be 'simple.' More
;  specifically, it must contain the NAXIS, CRVAL, CRPIX, and CDELT
;  keywords. These are the ONLY keywrods used, so any information
;  describing rotations, distortions, etc are ignored
;  --Only square pixels are allowed on putput (i.e. cdelt1 = cdelt2)
;
; BUGS: 
;  (potential): I don't know the difference betwwen Var(A-hat) and
;  Var(A) in equations 15-16. I treat them both as given in eq 13.
;
; FUNCTIONS USED:
;  SXPAR, SXADDPAR, MKHDR, PSF_GAUSSIAN
;
; CATEGORY:
;  Dereddening, Extinction, ISM
;
; MODIFICATION HISTORY:
;  September 1, 2008: Written by cnb
;
;-

;-MAGIC NUMBERS
TOL = 1.0 ; when sigma clipping, map must converge to within TOL*Variance
MAXITER = 10 ; maximum number of iterations before aborting

;-CHECK PARAMETERS

if n_params() lt 4 then begin
    print,'AVMAP CALLING SEQUENCE:'
    print,'avmap, avcat, fwhm, header, map, [sigma = sigma, varmap= varmap, /AUTO, /VERBOSE]'
    print,'avcat: A 4-by-n array of (x position, y position, AV, AV error)'
    print,'fwhm: The smooting kernel FWHM'
    print,'header: The fits header describing the output map'
    print,'map: The spatially smoothed AV map'
    print,'SIGMA: Set to use sigma clipping (value = sigma threshhold)'
    print,'VARMAP: Set to a named variable which will contain the variance on the AV map'
    print,'AUTO: Set this to automatically determine the size and scale of the output map'
    print,'VERBOSE: Set to print extra info'
    return
endif

sz = size(avcat)
if (sz[0] ne 2) || (sz[1] ne 4) then begin
    message,'AVCAT must be a 3-by-n array of (x position, yposition, AV)',/continue
    return
endif

;-DETERMINE OUTPUT MAP DIMENSIONS

if keyword_set(auto) then begin
;- determine header from avcat
    lox = min(avcat[0,*], max = hix)
    loy = min(avcat[1,*], max = hiy)
    crval1 = (lox + hix) / 2.
    crval2 = (loy + hiy) / 2.
    cdelt = fwhm / 10.
    naxis1 = round((hix - lox) / cdelt / 2) * 2 + 1
    naxis2 = round((hiy - loy) / cdelt / 2) * 2 + 1
    crpix1 = (naxis1 + 1) / 2
    crpix2 = (naxis2 + 1) / 2
    mkhdr, header, fltarr(naxis1,naxis2)
    sxaddpar, header, 'cdelt1', cdelt
    sxaddpar, header, 'cdelt2', cdelt
    sxaddpar, header, 'crval1', crval1
    sxaddpar, header, 'crval2', crval2
    sxaddpar, header, 'crpix1', crpix1
    sxaddpar, header, 'crpix2', crpix2
endif else begin
;use input header
    badhead='Input HEADER does not have good astrometry info. Aborting.'
    crval1 = sxpar(header, 'crval1', count=ct, /silent)
    if ct eq 0 then message, badhead
    crval2 = sxpar(header, 'crval2', count=ct, /silent)
    if ct eq 0 then message, badhead
    cdelt = sxpar(header, 'cdelt1', count=ct, /silent)
    if ct eq 0 then message, badhead
    cdelt2 = sxpar(header, 'cdelt2', count=ct, /silent)
    if ct eq 0 then message, badhead
    if cdelt2 ne cdelt then message, 'CDELT2 not equal to CDELT1. Using cdelt1 for both'
    crpix1 = sxpar(header, 'crpix1', count=ct, /silent)
    if ct eq 0 then message, badhead
    crpix2 = sxpar(header, 'crpix2', count=ct, /silent)
    if ct eq 0 then message, badhead
    naxis1 = sxpar(header, 'naxis1', count=ct, /silent)
    if ct eq 0 then message, badhead
    naxis2 = sxpar(header, 'naxis2', count=ct, /silent)
    if ct eq 0 then message, badhead
endelse

;-convert quantities into zero indexed pixel units
x = (reform(avcat[0,*]) - crval1) / cdelt + crpix1 - 1
y = (reform(avcat[1,*]) - crval2) / cdelt + crpix2 - 1
fwhm = round ( fwhm / cdelt ) 

;-reject sources that lie outside the image
in=where((x ge 0) and (x le (naxis1-1)) and (y ge 0) and (y le (naxis2-1)),ct)
if ct eq 0 then message,'No sources in AVCAT lie within the requested AV map'
x=x[in]
y=y[in]
av=reform(avcat[2,in])
var=reform(avcat[3,in])

;- some coordinate reference stuff to calculate smoothing kernel
npix = (4*fwhm) < (naxis1-1) < (naxis2-1)
xind = rebin(indgen(npix),npix,npix)
yind = rebin(reform(indgen(npix),1,npix),npix,npix)
left = 0 > ( round((x - npix/2.)) < (naxis1-npix) )
bot = 0 > ( round((y - npix/2.)) < (naxis2-npix) )

good=lindgen(n_elements(x))
attempt=1

;- start iteratively computing AV maps
AVSMOOTH:
if keyword_set(verbose) then print,'Begging iteration number '+string(attempt,format='(i2)')

;- add a small offset to prevent division by zero
map = fltarr(naxis1 , naxis2)+1e-10
wmap = fltarr(naxis1, naxis2)+1e-10
w2map = fltarr(naxis1, naxis2)+1e-10
varmap = fltarr(naxis1, naxis2)+1e-10

;- make the smoothed maps by looping through avcat
;- section 3.2.1, eqs 14-15 of L&A

ng=n_elements(good)
for i=0L, ng-1, 1 do begin
    if ((i mod (ng/10)) eq 0) && keyword_set(verbose) then $
        print, round(100.*i/n_elements(good)),format="(i3, ' percent complete')"
    temp = exp(-((xind+left[good[i]]-x[good[i]])^2. + (yind+bot[good[i]]-y[good[i]])^2.)$
               /(2*fwhm^2./(2.355)^2.))/var[good[i]]
    l=left[good[i]]
    b=bot[good[i]]
    wmap[l:l+npix-1,b:b+npix-1] += temp
    w2map[l:l+npix-1,b:b+npix-1] += temp^2
    map[l:l+npix-1,b:b+npix-1] += temp * av[good[i]]
    varmap[l:l+npix-1,b:b+npix-1] += temp^2 *var[good[i]]
endfor

map /= wmap
varmap /= w2map

;- iterate if sigma clipping
if keyword_set(sigma) then begin
    if attempt eq 1 then begin
        attempt++
        lastmap=map
        good = where(abs(av - map[x,y]) le sigma*varmap[x,y], ct)
        if ct eq 0 then message, 'Error in sigma clipping'
        goto, AVSMOOTH
    endif
    
    residual = abs(map-lastmap)/(TOL*varmap)
    worst=max(residual)
    avg=median(residual)
    if keyword_set(verbose) then begin
        print, avg,worst, format="('Average/Worst residuals: ',2(e8.1, ' '))"
    endif
    if worst ge 1 then begin
        if attempt eq maxiter then begin
            print, 'MAP failed to converge in '+strtrim(string(maxiter),2)+ ' iterations'
            return
        endif
        lastmap=map
        attempt++
        good = where(abs(av - map[x,y]) le sigma*varmap[x,y], ct)
        if ct eq 0 then message, 'Error in sigma clipping'
        goto, AVSMOOTH
    endif
endif 

end
