pro extast3_test

cube = fltarr(3,3,3)
mkhdr, chead, cube

sxaddpar, chead, 'crval1', 1
sxaddpar, chead, 'crval2', 1
sxaddpar, chead, 'crval3', 1

sxaddpar, chead, 'crpix1', 1
sxaddpar, chead, 'crpix2', 1
sxaddpar, chead, 'crpix3', 1


sxaddpar, chead, 'cdelt1', 1
sxaddpar, chead, 'cdelt2', 1
sxaddpar, chead, 'cd3_3', 1


extast3, chead, ext

help, ext, /struct
help, *ext.extast, /struct

print, *ext.extast

extast3, chead, ext, /delete
help, ext
help, /heap
end
