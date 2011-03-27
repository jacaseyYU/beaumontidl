;+
; PURPOSE:
;  This function concatenates 2 structures or structure arrays,
;  merging the tags from each input. It differs from the builtin
;  function CREATE_STRUCT in 2 ways. First, it can join entire arrays
;  of structures at once. Second, it can add prefixes to the tag names
;  to prevent duplicate tag names.
;
; INPUTS:
;  s1: The first structure. Scalar or array
;  s2: The second structure, Scalar or array. Must have same number of
;      elements as s1.
;  
; KEYWORD PARAMETERS:
;  prefix1: An optional string to prepend to the tag names in s1. Can
;           be used to avoid dupicate tag names in s1 and s2
;  prefix2: An optional string to prepend to the tag names in s2
;
; OUTPUTS:
;  A new structure or array of structures. The ith entry of the output
;  wlll consist of the data from s1[i] and s2[i].
;
; EXAMPLES:
;  IDL> s1 = {x:'one', y:2, z:3D}
;  IDL> s2 = {a:100, b:200}
;  IDL> help, join_struct(s1, s2), /struct
; 
; ** Structure <1619d08>, 5 tags, length=40, data length=30, refs=1:
;   X               STRING    'one'
;   Y               INT              2
;   Z               DOUBLE           3.0000000
;   A               INT            100
;   B               INT            200
;
;  IDL> help, join_struct(s1, s2, prefix1='PRE_'), /struct
;
; ** Structure <1532b58>, 5 tags, length=40, data length=30, refs=1:
;   PRE_X           STRING    'one'
;   PRE_Y           INT              2
;   PRE_Z           DOUBLE           3.0000000
;   A               INT            100
;   B               INT            200
;
; MODIFICATION HISTORY:
;  March 2011: Written by Chris Beaumont
;-
function join_struct, s1, s2, prefix1 = prefix1, prefix2 = prefix2

  if n_params() ne 2 then begin
     print, 'calling sequence'
     print, ' result = join_struct(s1, s2, [prefix1 = prefix1, prefix2 = prefix2])'
     return, !values.f_nan
  endif

  if size(s1, /type) ne 8 || size(s2, /type) ne 8 then $
     message, 's1 and s2 must be structures or structure arrays'

  n1 = n_elements(s1)
  n2 = n_elements(s2)

  if n1 ne n2 then $
     message, 's1 and s2 must have the same number of elements'

  name1 = tag_names(s1)
  name2 = tag_names(s2)
  if ~keyword_set(prefix1) then prefix1=''
  if ~keyword_set(prefix2) then prefix2=''
  
  for i = 0, n_elements(name1) - 1, 1 do begin
     hit = where( strmatch(prefix2 + name2, prefix1 + name1[i]), ct)
     if ct ne 0 then $
        message, 'Duplicate tag name: '+ name1[i]+' Try setting prefix'
  endfor


  cmd = 'rec = {'
  for i = 0, n_elements(name1) - 1, 1 do $
     cmd += string(prefix1 + name1[i], i, format='(a, ": s1[0].(", i0, "), ")')
  for i = 0, n_elements(name2) - 2, 1 do $
     cmd += string(prefix2 + name2[i], i, format='(a, ": s2[0].(", i0, "), ")')
  cmd += string(prefix2 + name2[i], i, format='(a, ": s2[0].(", i0, ")} ")')
  result = execute(cmd)

  result = replicate(rec, n1)
  
  for i = 0, n_elements(name1) - 1, 1 do $
     result[*].(i) = s1[*].(i)
  for i = 0, n_elements(name2) - 1, 1 do $
     result[*].(i+n_elements(name1)) = s2[*].(i)

  return, result
end

pro test
  x = {one:1., two:2, three:3D}
  y = {four:40, five:50L}
  help, join_struct(x,y, prefix1 = 'prefix1_'), /struct
end
