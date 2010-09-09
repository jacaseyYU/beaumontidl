pro mosaic_sobel

  m = mrdfits('mosaic.fits', 0, h)
  mask = erode(finite(reform(m[*,*,100])), replicate(1, 5, 5))
  nanswap, m, 0
  sz = size(m)
  m *= rebin(mask, sz[1], sz[2], sz[3])
  
  cnb_sobel3, m, x, y, z
  cnb_sobel3, sqrt(x^2+y^2), xx, yy, zz
  writefits, 'mosaic_gradx.fits', x, h
  writefits, 'mosaic_grady.fits', y, h
  writefits, 'mosaic_gradz.fits', z, h
  writefits, 'mosaic_zz.fits', zz, h
  stop
end
