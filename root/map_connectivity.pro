function map_connectivity, map, all_neighbors = all_neighbors

  sz = size(map)
  ndim = size(map, /n_dim)

  if ndim ne 2 then message, 'map must be a 2D array'

  lo = 0 & hi = max(map)+1

  result = bytarr(hi, hi)

  sh = shift(map, 1,0)
  sh[0,*] = map[0,*]
  result[map, sh] = 1 & result[sh, map] = 1
  assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

  sh = shift(map, -1,0)
  sh[sz[1]-1,*] = map[sz[1]-1,*]
  result[map, sh] = 1 & result[sh, map] = 1
  assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

  sh = shift(map, 0,1)
  sh[*,0] = map[*,0]
  result[map, sh] = 1  & result[sh, map] = 1
  assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

  sh = shift(map, 0,-1)
  sh[*,sz[2]-1] = map[*,sz[2]-1]
  result[map, sh] = 1 & result[sh, map] = 1
  assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

  if keyword_set(all_neighbors) then begin
     sh = shift(map, 1,1)
     sh[*,0] = map[*,0] & sh[0,*] = map[0,*]
     result[map, sh] = 1 &  result[sh, map] = 1
     assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1


     sh = shift(map, 1,-1)
     sh[*,sz[2]-1] = map[*,sz[2]-1] & sh[0,*] = map[0,*]
     result[map, sh] = 1 &  result[sh, map] = 1
     assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1


     sh = shift(map, -1,1)
     sh[*,0] = map[*,0] & sh[sz[1]-1,*] = map[sz[1]-1,*]
     result[map, sh] = 1 & result[map, sh] = 1
     assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

     sh = shift(map, -1,-1)
     sh[*,sz[2]-1] = map[*,sz[2]-1] & sh[sz[1]-1,*] = map[sz[1]-1,*]
     result[map, sh] = 1 &  result[sh, map] = 1
     assert, min(result[map,sh]) eq 1 && min(result eq transpose(result)) eq 1

  endif

  ;- some sanity checking
  assert, min(result[indgen(hi), indgen(hi)]) eq 1
  assert, max(result ne transpose(result)) eq 0

  return, result

end


pro test


;  conn = map_connectivity(im)
;  print, conn
  cols = map_color(im, /all)
  print,''
  print, cols
end

