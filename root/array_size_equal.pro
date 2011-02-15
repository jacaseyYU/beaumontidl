function array_size_equal, p, q, type = type

  szp = size(p)
  szq = size(q)

  if keyword_set(type) then $
     type_test = szp[szp[0]+1] eq szq[szq[0]+1] $
  else $
     type_test = 1

  return, array_equal(szp[0:szp[0]], szq[0:szq[0]]) and type_test
end

pro test

  a1 = fltarr(5,5)
  a2 = bytarr(5,5)
  assert, array_size_equal(a1, a2)
  assert, ~array_size_equal(a1, a2, /type)

  assert, array_size_equal(5, 6)
  assert, array_size_equal(fltarr(2,2,2), intarr(2,2,2))
  assert, array_size_equal(fltarr(2,2,2,2), intarr(2,2,2,2))
  assert, array_size_equal(fltarr(2,2,2,2,2), intarr(2,2,2,2,2))

  assert, ~array_size_equal(fltarr(5,2), fltarr(10))
  assert, ~array_size_equal([1], 1)

end
