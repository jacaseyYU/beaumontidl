pro edges
  common edges, im
  if n_elements(im) eq 0 then $
     im = mrdfits('mosaic.fits')

  m = reform(im[*,150,*])
  nanswap, m, 0
  cnb_sobel, m, mag, theta
  imlapdiff, m, x, y, d1, d2

  p1 = [.0, .0, .5, .5]
  p2 = [.5, 0, 1, .5]
  p3 = [.0, .5, .5, 1]
  p4 = [.5, .5, 1, 1]
  
  erase
  tvimage, bytscl(mag * cos(theta)), pos = p1, /keep
  tvimage, bytscl(mag * sin(theta)), pos = p2, /keep
  tvimage, bytscl(x), pos = p3, /keep
  tvimage, bytscl(y), pos = p4, /keep
end
