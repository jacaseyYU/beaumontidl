pro sky2pix_test

  ;- read in a test fits image. its a pathological case,
  ;- at a low declination, where all that spherical
  ;- geometry crap should be important

  im = mrdfits('test.fits',0,header, /silent)
  
  ;- random sky locations
  alpha = randomu(seed, 50) * 360
  dec = randomu(seed, 50) * 180 - 90
  vel = randomn(seed, 50) * 100
  coords = transpose([[alpha],[dec]])

  ;- test 1: 2D sky to data
  pix = sky2pix(header, coords)
  adxy, header, alpha, dec, x, y

  err = 1D-7
  assert, max(abs(x - pix[0,*]),/nan) lt err
  assert, max(abs(y - pix[1,*]),/nan) lt err
  print, '2 Dimensional sky-> data PASSED'
  x1 = x
  y1 = y
  
  ;- test 2: 2D data to sky
  pix = sky2pix(header, coords, /backwards)
  xyad, header, alpha, dec, x, y
  assert, max(abs(x - pix[0,*]),/nan) lt err
  assert, max(abs(y - pix[1,*]),/nan) lt err
  print, '2 Dimensional data -> sky PASSED'
  x2 = x
  y2 = y

  ;- test 3: 3D sky to data
  err = 1d-4
  crval3 = 20.
  crpix3 = 100.
  cdelt3 = 1.2
  sxaddpar, header, 'naxis', 3
  sxaddpar, header, 'crval3', crval3
  sxaddpar, header, 'crpix3', crpix3
  sxaddpar, header, 'cdelt3', cdelt3
  coords = transpose([[alpha],[dec],[vel]])
  pix = sky2pix(header, coords)
  z = (vel - crval3) / cdelt3 + crpix3 - 1
  assert, max(abs(z - pix[2,*]), /nan) lt err
  assert, max(abs(x1 - pix[0,*]), /nan) lt err
  assert, max(abs(y1 - pix[1,*]), /nan) lt err
  
  print, '3D sky -> data PASSED'

  ;- test 4
  coords = transpose([[alpha],[dec],[vel]])
  pix = sky2pix(header, coords, /backwards)
  z = (vel + 1 - crpix3) * cdelt3 + crval3
  assert, max(abs(z - pix[2,*]), /nan) lt err
  assert, max(abs(x2 - pix[0,*]), /nan) lt err
  assert, max(abs(y2 - pix[1,*]), /nan) lt err
  print, '3D data->sky PASSED'


  end
