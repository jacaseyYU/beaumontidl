function clip_border, im, border, value= value
  if ~keyword_set(value) then value = 0
  sz = size(im)
  ndim = size(im, /n_dimen)
  
  result = im
  result[0:border-1,*] = value
  result[sz[1]-border : *, *] = value
  result[*, 0:border-1] = value
  result[*, sz[2] - border: *] = value

  return, result
end
