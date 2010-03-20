pro coordtest

ra = 15. + [5, 10, 15, 20] / 3600D
dec = 3D + [0,0,0,0]

sxaddpar, h, 'crval1', ra[0]
sxaddpar, h, 'crval2', dec[0]
sxaddpar, h, 'cdelt1', 1/(3.6D3)
sxaddpar, h, 'cdelt2', 1/(3.6D3)
sxaddpar, h, 'crpix1', 1
sxaddpar, h, 'crpix2', 1

adxy, h, ra, dec, x, y
xyad, h, x, y, ra2, dec2
print, x, y
print, ra2, dec2

end
