pro image

  m = mrdfits('snr.fits', 0, h)
  
  indices, m, x, y, z
  xyzadv, h, x[0,0,*], y[0,0,*], z[0,0,*], a, d, v

  r1 = minmax(where(v gt 10 and v lt 37))
  r2 = minmax(where(v gt 37 and v lt 64))
  r3 = minmax(where(v gt 64 and v lt 91))

  blue = total(m[*,*,r1[0]:r1[1]], 3, /nan)
  green = total(m[*,*,r2[0]:r2[1]], 3, /nan)
  red = total(m[*,*,r3[0]:r3[1]], 3, /nan)

  sz = size(blue)
  im = fltarr(3, sz[1], sz[2])
  im[0,*,*] = red & im[1,*,*] = green & im[2,*,*] = blue

  tvimage, bytscl(sigrange(im > median(im))), /true

end
