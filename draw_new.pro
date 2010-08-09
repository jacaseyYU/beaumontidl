function draw_new, letters, played, letterbag, bad = bad
  bad = 0
  result = letters
  for i = 0, strlen(played) - 1, 1 do begin
     char = strmid(played, i, 1)
     if char ge 'A' and char le 'Z' then char='.'
     hit = strpos(result, char)
     if hit eq -1 then begin
        bad = 1
        return, !values.f_nan
     endif
     strput, result, ' ', hit
  endfor
  result = strjoin(strsplit(result, ' ', /extract))

  len = strlen(result)
  if len gt 7 then stop
  if len ne 7 then new = letterbag->draw(7 - len)
  result = [result, new]
  return, strjoin(result)
end
pro test
  letterbag = obj_new('letterbag')

  letters='abcdefg'
  played = 'deff'
  print, draw_new(letters, played, letterbag)
  obj_destroy, letterbag
end
