pro read_data
  common svmdata, data, h
  print, 'reading data'
  data = mrdfits('mosaic.fits',0,h)
  nanswap, data, 0
;  help, data
end
