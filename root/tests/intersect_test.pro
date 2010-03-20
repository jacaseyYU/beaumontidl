pro intersect_test

  ;- test the timing of the two methods

  sz = 100
  ntrial = sz
  max = 10^(1D * indgen(sz) / sz * 7)
  sparse = fltarr(sz)
  dense = fltarr(sz)
  best = fltarr(sz)

  vec1 = randomu(seed, sz)
  vec2 = 300 * randomu(seed, sz)

  ;XXX sparse chokes on 1 element arrays

  for i = 0, ntrial-1, 1 do begin
     print, i
     v1 = long(vec1 * max[i])
     v2 = long(vec2 * max[i])
     t1 = systime(/seconds)
     a1 = intersect(v1, v2, /sparse)
     t2 = systime(/seconds)
     a2 = intersect(v1, v2, /dense)
     t3 = systime(/seconds)
     a3 = intersect(v1, v2)
     t4 = systime(/seconds)
     assert, max(abs(a1 - a2)) eq 0 || (~finite(a1[0]) && ~finite(a2[0]))
     sparse[i] = t2 - t1
     dense[i] = t3 - t2
     best[i] = t4 - t3
  endfor
  
  print, minmax(dense)
  print, minmax(sparse)
  yra = minmax([minmax(dense), minmax(sparse)])
  plot, 2 * sz / max, dense, /xlog, psym = -4, /ylog, yra = yra, charsize = 1.5
  oplot, 2 * sz / max, sparse, psym = -4, color = fsc_color('red')
  oplot, 2 * sz / max, best, psym = -4, color = fsc_color('blue')
  ;- crossover seems to happen when range(data) / nelements ~ .01

end
