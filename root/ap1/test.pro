pro test
  ;;load an image
  fn = filepath('md1107g8a.jpg',SUBDIRECTORY='examples/data')
  image= read_image(fn)
  image90 = rotate(image,1)

  n = n_elements(image)

  ;;take fft of image, then get the real and imaginary parts
  f = fft(image)
  fr = real_part(f)
  fi = imaginary(f)

  ;;take the fft of image90 then get the real and imaginary parts.
  f90 = fft(image90)
  fr90 = real_part(f90)
  fi90 = imaginary(f90)
  
  ;- display stuff
  window, 1, xsize = 750, ysize = 500, retain= 2
  
  tvscl, fr, 0, 250
  tvscl, fr90, 250, 250
  tvscl, fr - fr90, 500,250
  tvscl, fi, 0, 0
  tvscl, fi90, 250, 0
  tvscl, fi90, 500, 0
  

end
