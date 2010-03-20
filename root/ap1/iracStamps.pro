;-
; NAME:
;  iracStamps
;
; DESCRIPTION:
;  Makes a wide fits file postagestamp of bubbles in our sample. Saves
;  them to ~/irac/
;-

pro iracStamps

files = file_search('/users/cnb/glimpse/pro/shells/saved/*.sav', count=ct)
if ct eq 0 then begin
    print, 'no files'
    return
endif

field = findgen(30) * 3
stoppers = [54]
for i = 0, ct-1, 1 do begin
    bubble = strsplit(files[i],'/',/extract)
    bubble = strsplit(bubble[n_elements(bubble)-1],'.',/extract)
    bubble = long(bubble[0]) 
    
    doStop = where(stoppers eq bubble, ct)
    if ct eq 0 then continue

    print, bubble, format="('Starting Bubble ', i3)"
    loc = getBubblePos(bubble)
    d = abs(mean(loc[*,0]) - field)
    lon = field[where(d eq min(d))]
    irac = string(lon, format="('~/glimpse/fits/mosaic/GLM_',i3.3,'00+0000_mosaic_I4.fits')")
    if ~file_test(irac) then message, 'File DNE: '+irac
    
    irac = mrdfits(irac, 0, h, /silent)
    
    crval1 = mean(loc[*,0])
    crval2 = mean(loc[*,1])
    cdelt1 = -2 / 3600.
    cdelt2 = 2 / 3600.
    naxis1 = ceil(.6 / cdelt1)
    naxis2 = ceil(.6 / cdelt2)
    crpix1 = naxis1 / 2
    crpix2 = naxis2 / 2
    irac = postagestamp(irac, h, [crval1,crval2], [.6, .6], [cdelt1, cdelt2], /nan)
    mkhdr, head, irac
    sxaddpar, head, 'ctype1', 'GAL-LON'
    sxaddpar, head, 'ctype2', 'GAL-LAT'
    sxaddpar, head, 'crval1', crval1
    sxaddpar, head, 'crval2', crval2
    sxaddpar, head, 'crpix1', crpix1
    sxaddpar, head, 'crpix2', crpix2
    sxaddpar, head, 'cdelt1', cdelt1
    sxaddpar, head, 'cdelt2', cdelt2
    writefits,string(bubble, format='("~/irac/",i3.3,".fits")'), irac, head
endfor

return
end
