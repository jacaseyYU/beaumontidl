function neighbor_offsets, array, all_neighbors = all_neighbors

  if n_elements(array) eq 0 then begin
     print, 'calling sequence'
     print, 'result = neighbor_offsets(array, [/all_neighbors])'
  endif

  sz = size(reform(array)) & nd = sz[0]
  if nd eq 1 then begin
     result = [-1, 1]
  endif else if nd eq 2 then begin
     for i = -1, 1 do begin
        for j = -1, 1 do begin
           if i eq 0 && j eq 0 then continue
           if ~keyword_set(all_neighbors) && i ne 0 && j ne 0 then continue
           result = append(result, i + sz[1] * j)
        endfor
     endfor
  endif else if nd eq 3 then begin
     for i = -1, 1 do begin
        for j = -1, 1 do begin
           for k = -1, 1 do begin
              if i eq 0 && j eq 0 && k eq 0 then continue
              corner = ((i ne 0) + (j ne 0) + (k ne 0)) gt 1
              if ~keyword_set(all_neighbors) && corner then continue
              result = append(result, i + sz[1] * j + sz[1] * sz[2] * k)
           endfor
        endfor
     endfor
  endif else message, 'Array must be 1-3 dimensions'
  return, result
end

pro test

  x = fltarr(10)
  assert, array_equal(neighbor_offsets(x),  [-1, 1])
  x = fltarr(5, 7)
  assert, array_equal(neighbor_offsets(x), [-1, -5, 5, 1])
  assert, array_equal(neighbor_offsets(x, /all), [-6, -1, 4, -5, 5, -4, 1, 6])

  x = fltarr(2,2,8)
  assert, array_equal(neighbor_offsets(x), [-1, -2, -4, 4, 2, 1])

  assert, n_elements(neighbor_offsets(x, /all)) eq 26
end
