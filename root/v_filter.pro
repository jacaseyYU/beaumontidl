function v_filter, im, intensity, width

  sz = size(im)
  nsigma = 2D
  thresh = intensity / (width * .5)
  dx = 1 > (width / 2.)

  cnb_sobel, im, mag, theta
  tvscl, mag * cos(theta)
  stop
  
  gradient = mag * cos(theta)
  up = gradient gt thresh
  down = gradient lt (-1 * thresh)
  
  result = up * 0
  for i = 2 * dx, sz[1] - 2 * dx, 1 do $
     result[i, *] = (result[i-1, *] or up[i,*]) and not $
                    (~down[i,*] and down[i-1,*])
  assert, min(result, max=hi) ge 0 && hi le 1
  return, result * im
end


pro test

  im = mrdfits('~/Desktop/M17_loop/mosaic.fits',0,h)
  im = reform(im[150, *, *])

  kern = [1, .5, 0, .5, 1]
  kern = rebin(kern, 5, 5)
  kern /= total(kern)
  wset, 0
  tvscl, 0 > im < 5

  wset, 1
  
  cnb_sobel, im, mag, theta
  ;tvscl, mag * cos(theta)
  tvscl, morph_open(im gt 1.2, replicate(1,3,3))
;  tvscl, morph_close(mag, replicate(1,2,2))

  return
;  im = median(im, 10)
  a = 3.
  sigma = 5.
;  a = 10
;  sigma = 30.  
;  x = arrgen(-5 * sigma, 5 * sigma, 1)
;  y = a * exp(-x^2 / (2 * sigma^2))
;  sz = size(y)
;  im = rebin(y, sz[1], sz[1])
;  im += randomn(seed, n_elements(im)) * a/

  sz = size(im)
  window, 0, xsize = sz[1], ysize = sz[1]
  tvscl, im

  window, 1, xsize = sz[1], ysize = sz[1]
  filter = v_filter(im, a, sigma)
  tvscl, filter * (1 - (im gt 9.99))
end
