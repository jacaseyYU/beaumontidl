;+
; NAME:
;  DENSITYMAP
;
; DESCRIPTION:
;  This procedure is modeled on SMOOTHMAP.PRO, which makes a smoothed
;  map of an irregularly sampled quantity over the sky. This function
;  creates a smooth density map based on a set  of observed
;  objects. It was implemented to visualize the suface density of YSOs
;  in Spitzer GLIMPSE data.
;
; CALLING SEQUENCE:
;  DENSITYMAP, x, y, map, head, [cdelt = cdelt, fwhm = fwhm, out =
;  out, /CLIP, /GALACTIC]
;
;-
PRO DENSITYMAP, x, y, map, head, cdelt = cdelt, aper = aper, out = out, $
                clip = clip, galactic = galactic, verbose = verbose

compile_opt idl2
;on_error, 2

dbl_radeg = 180D / (!dpi)
dbl_dtor = (!dpi) / 180D

;-check for proper input
if n_params() ne 4 then begin
    print, 'DENSITYMAP calling sequence: '
    print, 'densitymap, x, y, map, head, [cdelt = cdelt, aper = aper, out = out'
    print, '            /clip, /galactic, /verbose]'
    return
endif

sz = n_elements(x)
if n_elements(y) ne sz  then message, 'x and y variables must be the same size'

;-set up output map
if keyword_set(GALACTIC) then begin
    ctype1 = 'GLON-CAR'
    ctype2 = 'GLAT-CAR'
endif else begin
    ctype1 = 'RA-CAR'
    ctype2 = 'DEC-CAR'
endelse

xra = minmax(x)
yra = minmax(y)

;- All measurements in DEGREES
crval1 = mean(xra)
crval2 = mean(yra)

;- default to 50 sources per 1 aperture
if ~keyword_set(aper) then begin
    objPerCell = 50;
    area = (yra[1] - yra[0]) * (xra[1] - xra[0]) * cos(crval2 * dbl_dtor)
    aper = sqrt(area * objPerCell / (sz * !pi)) 
endif

;- default to 2 pixels per aperture
if ~keyword_set(cdelt) then begin
    cdelt1 = -aper / 2
    cdelt2 = aper / 2
    cdelt = cdelt2
endif else begin
    cdelt1 = -abs(cdelt)
    cdelt2 =  abs(cdelt)
endelse

naxis1 = ceil((xra[1] - xra[0]) * cos(crval2 * dbl_dtor) / cdelt2)
naxis2 = ceil((yra[1] - yra[0]) / cdelt2)

crpix1 = (naxis1 + 1) / 2.
crpix2 = (naxis2 + 1) / 2.

mkhdr, head, 4, [naxis1, naxis2]
sxaddpar, head, 'CTYPE1', ctype1
sxaddpar, head, 'CTYPE2', ctype2
sxaddpar, head, 'CRVAL1', crval1, 'DEGREES'
sxaddpar, head, 'CRVAL2', crval2, 'DEGREES'
sxaddpar, head, 'CRPIX1', crpix1, '1-based'
sxaddpar, head, 'CRPIX2', crpix2, '1-based'
sxaddpar, head, 'CDELT1', cdelt1, 'DEGREES / PIXEL'
sxaddpar, head, 'CDELT2', cdelt2, 'DEGREES / PIXEL'
sxaddpar, head, 'BMAJ', aper, 'aperture in DEGREES'
sxaddpar, head, 'BMIN', aper, 'aperture in DEGREES'
sxaddpar, head, 'BUNIT','Sources / square degree'

map = dblarr(naxis1, naxis2)

;- an npix by npix postage stamp around a source should cover >1 aper
;  in angular distance
warp = min(cos(y * dbl_dtor)) ;- worst case warping of x axis away from the equator
npix = ceil(2.5 * aper / (cdelt2 * warp)) 
pix = dindgen(npix) - (npix -1) / 2.

stampxpix = rebin(pix, npix, npix)
stampypix = rebin(1#pix, npix, npix)

stampxsky = stampxpix * cdelt1
stampysky = stampypix * cdelt2

;- pixel locations of each source, 0 indexed
x_pix = (x - crval1) / cdelt1 + crpix1 - 1
y_pix = (y - crval2) / cdelt2 + crpix2 - 1

t0 = systime(/seconds)
elapsed = 0


if keyword_set(VERBOSE) then begin
    print, ''
    print, 'Beginning map calculation on '+systime()
endif

for i = 0, sz - 1, 1 do begin
    if ~finite(x[i]) || ~finite(y[i]) then continue

    ;- calculate which pixels in the postage stamp are within the aperture
    xstamp = 0 > round(stampxpix + x_pix[i]) < (naxis1 - 1)
    ystamp = 0 > round(stampypix + y_pix[i]) < (naxis2 - 1)
    gcirc, 0, x[i] * dbl_dtor, y[i] * dbl_dtor, $
      (x[i] + stampxsky) * dbl_dtor, (y[i] + stampysky) * dbl_dtor, dis
 
   dis *= dbl_radeg
   
    ;- update map
    map[xstamp, ystamp] += dis lt aper
    
    if KEYWORD_SET(VERBOSE) && (i mod 100) eq 0 && (systime(/seconds) - t0) ge 10 then begin
        elapsed += systime(/seconds) - t0
        t0 = systime(/seconds)
        print, elapsed, ((sz - 1.) / i - 1) * elapsed, format='("Time Elapsed / Remaining (s): ", i, " / ", i)'
    endif

endfor

if KEYWORD_SET(VERBOSE) then begin
    print, 'Map calculation finished on  '+systime()
    print, ''
endif

;-convert map counts from counts / aperture to counts / sq degree
aperArea = !dpi * aper^2
map /= aperArea

;-write out files
if keyword_set(out) then begin
    split = strsplit(out, '.',/extract)
    if split[n_elements(split)-1] ne '.fits' then out=out+'.fits'
    writefits, out, map, head
endif

return

end
