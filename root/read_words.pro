;+
; PURPOSE:
;  This function returns all of the words (technically,
;  whitespace-delimited character sequences) in a file as a string
;  array
;
; INPUTS:
;  file: The name of a file
;
; OUTPUTS:
;  The words in the file, as a string array
;
; MODIFICATION HISTORY:
;  December 2010: Written by Chris Beaumont
;-
function read_words, file
  if n_elements(file) eq 0 then begin
     print, 'calling sequence'
     print, ' result = read_words(file)'
     return, -1
  endif

  if ~file_test(file) then $
     message, 'Cannot find file: '+file

  lines = file_lines(file)
  data = strarr(lines)

  openr, lun, file, /get
  readf, lun, data, format='(a)'
  free_lun, lun

  s = obj_new('stack')
  for i = 0L, lines - 1, 1 do begin
     s->push, strsplit(data[i], ' ', /extract)
  endfor
  
  result = s->toArray()
  obj_destroy, s

  return, result
end
