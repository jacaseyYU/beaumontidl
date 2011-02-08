pro rot3, cube, angle

  if n_params() ne 2 then begin
     print, 'calling sequence'
     print, 'result = rot3(cube, angle)'
  endif
  
  sz = size(cube)
  if sz[0] ne 3 then $
     message, 'input must be a cube!'

  result = cube

  for i = 0, sz[3] - 1, 1 do $
     result[*,*,i] = rot( reform(cube[*,*,i]), angle)

  return, result
end
