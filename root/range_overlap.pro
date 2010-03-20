function range_overlap, lo, hi
  num = n_elements(lo)

  vals = [reform(lo,num), reform(hi,num)]
  vals = vals[sort(vals)]
  linds = value_locate(vals, lo)
  hinds = value_locate(vals, hi)
  fill = byte(vals * 0)
  for i = 0L, num-1, 1 do $
     fill[linds[i]:hinds[i]] = 1
  delta = vals - shift(vals,1)
  delta[0] = delta[1]
  return, total(delta[where(fill)])
end


pro test

  lo = indgen(1)
  hi = lo + 2
  print, range_overlap(lo,hi)
end
