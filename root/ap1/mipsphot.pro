;+
; NAME:
;  mipsstat
;
; CALLING SEQUENCE:
;  mipsstat, <bubble number>
;
; DESCRIPTION:
;  Interactively identifies MIPS sources in an image, and performs
;  crude aperture photometry on them
;
;-

pro mipsphot, bubble ,fresh = fresh
;on_error, 2
if n_params() eq 0 then begin
    print, 'calling sequence: mipsstat, bubblenumber'
    return
endif

if (bubble le 0) or (bubble ge 135) then message, 'bubble number out of bounds'
;-get bubble info
;- get bubble info
readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags, format='a,f,f,f,f,f,f,f,f,f,a'

hit = bubble - 1
l = l[hit]
b = b[hit]

;- open and trim MIPS file
mipsfile = '/users/cnb/mipsgal/MG0'+string(round(l), format='(i2.2)')+'0'
mipsfile += (b gt 0) ? 'p005_024.fits' : 'n005_024.fits'

if ~file_test(mipsfile) then message,'MIPS image not found: '+mipsfile
bigim = mrdfits(mipsfile, 0, h, /silent)
;- hack header file to overwrite CRVAL keywords to (l,b)
racen = sxpar(h, 'crval1')
decen = sxpar(h, 'crval2')
euler, racen, decen, lcen, bcen, 1
sxaddpar, h, 'crval1', lcen
sxaddpar, h, 'crval2', bcen
ast=nextast(h)
im = postagestamp(bigim, h, [l, b], [.25, .25], ast.cd[[0, 3]])

;- open the previous source catalog, if any
catfile = '/users/cnb/mipsgal/'+string(bubble, format='(i3.3)')+'.cat'

catalog = fltarr(1000, 4)
if keyword_set(fresh) || ~file_test(catfile) then begin
    print, 'No pre-existing source catalog. Creating a new one'
    nobj = 0;
endif else begin
    print, 'Opening old source catalog'
    readcol, catfile, cl, cb, cm, ce, /silent
    nobj = n_elements(cl)
    catalog[0:nobj-1,0] = cl
    catalog[0:nobj-1,1] = cb
    catalog[0:nobj-1,2] = cm
    catalog[0:nobj-1,3] = ce
endelse

;-display image and set up photometry
sz = size(im)
window, 0, xsize=sz[1], ysize=sz[2], retain = 2
aperture = 12
skyap = [17, 25]
phpadu = 5 * .0447 ;- e- / image counts

;- capture 1
print, 'using stretch 1 / 4'
catalog = sourcetag (im, .95, catalog, aperture, $
                     phpadu, skyap, nobj, ast, l, b)

;- capture 2
print, 'using stretch 2 / 4'
catalog = sourcetag (im, .98, catalog, aperture, $
                     phpadu, skyap, nobj, ast, l, b)

;- capture 3
print, 'using stretch 3 / 4'
catalog = sourcetag (im, .995, catalog, aperture, $
                     phpadu, skyap, nobj, ast, l, b)

;- capture 4
print, 'using stretch 4 / 4'
catalog = sourcetag (im, .9999, catalog, aperture, $
                     phpadu, skyap, nobj, ast, l, b)


;-save out catalog
openw, 1, catfile

printf, 1, transpose(catalog[0:nobj-1, *])
close, 1
close
end

function sourcetag, im, fraction, catalog, aperture, phpadu, skyap, nobj, ast, l, b
imdisp = im
bad = where(~finite(imdisp), ct)
sz = size(imdisp)
if ct ne 0 then imdisp[bad] = min(where(finite(imdisp)))
tv, bytscl(sigrange(imdisp, fraction=fraction))
if nobj gt 0 then $
  tvcircle, aperture, $
  (catalog[0:nobj-1,0] - l) / ast.cd[0] + sz[1] / 2 - 1, $
  (catalog[0:nobj-1, 1] - b) / ast.cd[3] + sz[2] / 2 - 1, $
  color='00ff00'xl, /device

while(1) do begin
    cursor, x, y, 3, /device
    if (x lt 50) && (y lt 50) then break ;
    
    ;- centroid
    cntrd, im, x, y, xcen, ycen, aperture / 3, /silent
    if (~finite(xcen)) || ~finite(ycen) || $
      (xcen eq -1) || (ycen eq -1) then continue
    x = xcen
    y = ycen

    ;- convert to sky coords
    star_l = (x + 1 - sz[1] / 2) * ast.cd[0] + l
    star_b = (y + 1 - sz[2] / 2) * ast.cd[3] + b
    aper, im, [x], [y], mag, magerr, sky, skyerr, phpadu, aperture, skyap,/nan,/silent
    catalog[nobj++, *] = [star_l, star_b, mag[0], magerr[0]]
    tvcircle, aperture, x, y, color='00ff00'xl, /device
endwhile
 
return, catalog
end
