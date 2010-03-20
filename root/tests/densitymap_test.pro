pro densitymap_test
compile_opt idl2
x = randomn(3, 5000)
y = randomn(5, 5000)

densitymap, x, y, 50, map, emap, head, verbose = 4, $
            naxis = 100
erase
print, sxpar(head, 'crval1')
print, sxpar(head, 'crval2')
print, sxpar(head, 'cdelt1')
print, sxpar(head, 'cdelt2')
print, sxpar(head, 'naxis1')
print, sxpar(head, 'naxis2')
print, sxpar(head, 'crpix1')
print, sxpar(head, 'crpix2')
;densitymap, x, y, 50, map, emap, head, /cartesian, /debug, verbose = 4
;print, minmax(map)


help, map
ctload, 24, /brewer
tvimage, bytscl(map), /keep
end
