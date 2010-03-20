pro cnb_sobel, image, mag, theta
  xmask = float([[-1, 0, 1],[-2, 0, 2], [-1,0,1]])
  ymask = float([[1,2,1], [0,0,0], [-1, -2, -1]])

  gx = convol(image, xmask, /center)
;  gx = clip_border(gx, 2)
  gy = convol(image, ymask, /center)
;  gy = clip_border(gy, 2)

  theta = atan(gy, gx)
  mag = abs(gx) + abs(gy)
end


pro test

  file = FILEPATH('nyny.dat', $ 
                  SUBDIRECTORY = ['examples', 'data']) 
  imageSize = [768, 512] 
  im = float(READ_BINARY(file, DATA_DIMS = imageSize))

  cnb_sobel, im, mag, theta
  s = sobel(im)

  wset, 0
  erase
  tvimage, bytscl(s), /keep
  wset, 1
  erase
  tvimage, bytscl(mag), /keep
  print,minmax(mag - s)
end
