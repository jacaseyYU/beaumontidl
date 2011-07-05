function find_definitions, input, count = count, file = file
  if keyword_set(file) then begin
     if ~file_test(input) then $
        message, 'input does not correspond to a valid file'
     openr, lun, input, /get
     nline = file_lines(input)
     data = strarr(nline)
     readf, lun, data, format='(a)'
     free_lun, lun
  endif else data = input

  regex = '^[\ ]*(pro|function)'
  
  nline = n_elements(data)
  for i = 0, nline - 1, 1 do begin
     ind = stregex(data[i], regex)
     if ind eq -1 then continue
     en = strpos(data[i], ',')
     if en eq -1 then en = strlen(data[i])
     st = strpos(data[i], ' ', en, /reverse_search)
     name = strmid(data[i], st + 1, en - st - 1)
     result = append(result, name)
  endfor
  count = n_elements(result)
  if n_elements(result) eq 0 then return, ''
  return, result
end

pro test

  assert, array_equal( $
           find_definitions('find_definitions.pro', /file), $
           ['find_definitions', 'test'])
  f = this_file()
  assert, array_equal($
          find_definitions(f), $
          ['find_definitions', 'test'])

end
