function _assign_value, conn, result, choices, todo, option, sp
  ;- conflict 1: option has already been excluded for todo
  if (result[todo] and option) eq 0 then begin
     ;print, sp+strtrim(option,2)+'not a valid option'
     return, 0
  endif

  ;- conflict 2: Assigning option to todo eliminates
  ;- all options for a neighbor
  neighbors = where(conn[todo,*], ct)
  if ct eq 0 then begin
     result[todo] = option
     choices[todo] = 0
     return, 1
  endif

  change = (result[neighbors] and option) ne 0
  conflict = (result[neighbors] and not option) eq 0
  if max(conflict) ne 0 then begin
     ;print, sp+strtrim(option, 2)+'would conflict with neighbors', neighbors[where(conflict)], $
;            result[neighbors[where(conflict)]], choices[neighbors[where(conflict)]]
     nn = where(conn[neighbors[(where(conflict))[0]],*])
     ;print, nn
     return, 0
  endif

  ;- no immediate conflicts. Try assigning the new value
  result[neighbors] = result[neighbors] and not option
  result[todo] = option
  choices[todo] = 0
  
  ;- update the choices array
  hit = where(change, ct)
  if ct ne 0 then begin
     choices[neighbors[hit]] -= 1
     assert, min(choices[neighbors[hit]]) ge 1
  endif
  return, 1
end
  

function recursive_map_fill, conn, result, choices, sp
  if n_elements(sp) eq 0 then sp = ' '

  ;- which regions have we not yet assigned?
  todo = where(choices ne 0, ct)
  if ct eq 0 then begin
     ;print, sp+'map successful'
     return, 1
  endif

  todo = todo[sort(choices[todo])]
  todo = todo[0]
  ;print, sp+'trying element ', todo, choices[todo], result[todo]

  ;- try each possibility
  old_r = result & old_c = choices
  for index = 0, 3, 1 do begin
     option = 2^index
     ;print, todo, option
     if not _assign_value( conn, result, choices, todo, option,sp) then continue
     if recursive_map_fill( conn, result, choices, sp + '  ') then return, 1
     choices = old_c & result = old_r
  endfor

  ;print, sp + 'no valid options for ', todo
  result[todo] = 0
  return, 0
end

pro assert_success, conn, color
  sz = size(conn)
  for i = 0, sz[1] - 1, 1 do begin
     conn[i,i] = 0
     neighbors = where(conn[i,*], ct)
     if ct eq 0 then continue
     conn[i,i] = 1
     if max(color[neighbors] eq color[i]) eq 1 then $
        message, 'map coloring failed at index '+strtrim(i,2)
  endfor
end

function map_color, map, all_neighbors = all_neighbors

  nd = size(map, /n_dim)
  if nd ne 2 then message, 'map must be 2D'
  
  if max(map) lt 0 then message, 'map must have at least one non-negative value'

  ;- re-label map to remove negative / missing indices
  map_in = fix(map)
  vals = map_in[uniq(map_in, sort(map_in))]
  map_in = value_locate(vals, map_in)
  assert, min(map_in) eq 0

 
  ;- calculate the connectivity matrix
  ;print, 'connectivity'
  conn = map_connectivity(map_in, all_neighbors = all_neighbors)
  ;print, 'done'

  ;- now trim away the rows/cols associated with negative labels
  good = min(where(vals ge 0))
  conn = conn[good:*, good:*]

  sz = size(conn)
  ;- zero out the diagonals. Makes life easier
  conn[indgen(sz[1]), indgen(sz[1])] = 0

  result = bytarr(sz[1]) + (1 or 2 or 4 or 8)
  choices = replicate(4, sz[1])

  ;- determine the map colors
  assert, recursive_map_fill(conn, result, choices)

  ;- convert result array into indices of 1-4
  sanity = (result and 1) ne 0 + $
           (result and 2) ne 0 + $
           (result and 4) ne 0 + $
           (result and 8) ne 0
  assert, max(sanity, min=lo) eq 1 && lo eq 1
  result = byte(alog(result) / alog(2)) + 1

  ; color the map
  color = byte(map * 0)

  h = histogram(map_in, min = good, rev = ri)
  for i = 0, n_elements(h) - 1, 1 do begin
     if h[i] eq 0 then continue
     color[ri[ri[i] : ri[i+1] - 1]] = result[i]
  endfor

  return, color
end

pro test
  im = intarr(10,10)
  im[0:3, 0:3] = 1
  im[4:7,4:7] = 30

  cols = map_color(im,/all)
  ;print, cols
end
