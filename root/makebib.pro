function strip, name
  result = ''
  for i = 0, strlen(name), 1 do begin
     letter = strmid(name, i,1)
     if stregex(letter, '[a-z]', /fold) eq 0 then $
        result += letter
  endfor

  return, result
end


pro makebib, file

  file = '~/parallax_papers/raw.bib'
  if ~file_test(file) then $
     message, 'file not found'

  array = strarr(10000)
  a = ''

  openr, lun, file, /get_lun
  i = 0

  while ~eof(lun) do begin
     readf, lun, a
     array[i++] = a
  endwhile
  close, lun
  free_lun, lun
  array = array[0:i]

  article_rows = where(strmatch(array, '@*'), ct)
  author_rows = where(strmatch(array, '   author = *'))
  year_rows = where(strmatch(array,   '     year = *'))

  if ct eq 0 then message, 'cant find any articles'
  
  for i = 0, ct -1, 1 do begin
     ;- get the author last name
     loc = strpos(array[author_rows[i]], ',')
     author = strmid(array[author_rows[i]], 14, loc - 15)
     year = strmid(array[year_rows[i]], 14, 2)
     
     loc = strpos(array[article_rows[i]], '{')
     header = strmid(array[article_rows[i]], 0, loc+1)
     array[article_rows[i]] = header+strip(author)+year+','
     print, strip(author)+year
  endfor


  
  file = '~/parallax_papers/my_bib.bib'
  openw, lun, file, /get_lun
  for i = 0, n_elements(array) - 1, 1 do begin
     printf, lun, array[i]
  endfor

  close, lun
  free_lun, lun

end
