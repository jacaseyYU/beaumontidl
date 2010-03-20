function cnb_flip, image, x = x, y = y, both = both
  compile_opt idl2

  ndimen = size(image, /n_dimen)
  if ndimen ne 2 then $
     message, 'image must be a 2d array'

  sz = size(image)

  x = indgen(sz[1])
  y = indgen(sz[2])
  
  x = rebin(x, sz[1], sz[2])
  y = rebin(1#y, sz[1], sz[2])
  
  if keyword_set(x) then begin
     x = sz[1] - 1 - x
     return, image[x,y]
  endif

  if keyword_set(y) then begin
     y = sz[2] - 1 - y
     return, image[x,y]
  endif

  if keyword_set(both) then begin
     y = sz[2] - 1 - y
     x = sz[1] - 1 - x
     return, image[x,y]
  endif

  message, 'must choose /x, /y, /xy'
  return, 0
end

