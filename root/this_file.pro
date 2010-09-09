;+
; PURPOSE:
;  This function returns the contents of the file in which the call to
;  this_file() appears. It is useful for saving a copy of the code
;  used to generate a particular save file.
;
; INPUTS:
;  none
;
; OUTPUTS:
;  A string array containing the contents of the file in which the
;  call to this_file() appears. If this_file() was called from the
;  command line, then the empty string is returned.
;
; EXAMPLE:
;  Consider a file containing the following program:
;    pro test
;      print, this_file()
;    end
;  Compiling and running test prints the following
;    pro test
;      print, this_file()
;    end
; 
;  The intended use for the program is, e.g.:
;   file = this_file()
;   ... other commands to create a variable "var" ...
;   save, var, file, file='out.sav'
;
;  Which saves a copy of the code used to generate var, in case the
;  original file changes over time.
;
; MODIFICATION HISTORY:
;  August 16 2010: Written by Chris Beaumont
;-
function this_file
  trace = scope_traceback(/struct)
  ind = n_elements(trace)-2
  filename = trace[ind].filename
  if filename eq '' then return, ''

  openr, lun, filename, /get_lun
  nline = file_lines(filename)
  result = strarr(nline)
  readf, lun, result
  free_lun, lun
  return, result
end

function recursive_call_thisfile, iter
  if iter eq 0 then return, this_file() else $
     return, recursive_call_thisfile(iter-1)
end

pro test
  f1 = this_file()
  f2 = recursive_call_thisfile(1)
  f3 = recursive_call_thisfile(5)
  assert, array_equal(f1, f2)
  assert, array_equal(f1, f3)
end
