;+
; PURPOSE:
;  This function finds and returns any occurances of substrings,
;  defined by certain beginning and ending strings.
;
; CATEGORY:
;  String processing
;
; INPUTS:
;  string: A string to search through
;  first: A string marking the beginning of each substring to search
;         for
;  last: A string marking the end of each substring
;
; OUTPUTS:
;  A string array. Each element of the output consists of the
;  characters found between an occurance of FIRST and LAST in the
;  input string.
function parsebetween, string, first, last
  
  skip = strlen(first)
  len = strlen(first) + strlen(last)

  loc = 0
  hit = strpos(string, first, loc)
  if hit eq -1 then return, ''
  hit2 = strpos(string, last, hit+1)
  if hit2 eq -1 then return, ''
 
  result = obj_new('stack')
  
  while hit2 ne -1 do begin
     result->push, strmid(string, hit + skip, (hit2 - hit - len+1))
     hit = strpos(string, first, hit2)
     if hit eq -1 then break
     hit2 = strpos(string, last, hit+1)
  endwhile
  array = result->toArray()
  obj_destroy, result
  return, array
end
