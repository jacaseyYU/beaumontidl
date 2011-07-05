;+
; PURPOSE:
;  Recursively find all of the dependencies contained a file of IDL
;  code. Useful for determing what files to include in a
;  self-contained bundle of IDL code.
;
; INPUTS:
;  start: The name of a file to find dependencies for.
;
; KEYWORD PARAMETERS:
;  only_source: If set, only return dependencies for which
;  corresponding source code is found. This will filter out
;  dependencies to IDL built in functions (like print), but will also
;  ignore potentially problematic missing dependencies. 
;
;  no_source: If set, only return dependencies for which corresponding
;  source code is not found. This will return calls to built-in
;  functions, as well as missing dependencies.
;
; OUTPUTS:
;  A structure array with the following tags:
;   func: The name of a function recognized as a dependency of start
;   source: The path of the IDL file that was found to contain the
;           code for func, if found. Otherwise, the empty string
;
; RESTRICTIONS:
;  This code inherits all the restrictions in finddep_line. Please see
;  that file for details. Caveat emptor.
;
; MODIFICATION HISTORY:
;  January 2011: Written by Chris Beaumont
;-
function finddep_all, start, only_source = only_source, no_source = no_source
  compile_opt idl2
  on_error, 2

  if n_params() ne 1 then begin
     print, 'Calling sequence:'
     print, 'result = finddep_all(start, [/only_source, /no_source])'
     return, !values.f_nan
  endif
  
  if keyword_set(only_source) && keyword_set(no_source) then $
     message, 'Cannot set /only_source and /no_source'

  ;catch, error
  ;if error ne 0 then begin
  ;   catch, /cancel
  ;   if obj_valid(x) then obj_destroy, x
  ;   if obj_valid(h) then obj_destroy, h
  ;   if obj_valid(r) then obj_destroy, r
  ;   print, !error_state.msg_prefix + !error_state.msg
  ;  print, 'aborting'
  ;   return, 0
  ;endif

  s = obj_new('stack')
  h = obj_new('hashtable')
  r = obj_new('hashtable')

  rec={func:'', source:''}

  dep = finddep_file(start, count, definition = d, defct = dct)
  if count ne 0 then s->push, dep

  for i = 0, dct - 1, 1 do $
     h->add, d[i], {func:d[i], source:start}, /replace
  for i = 0, count - 1, 1 do $
     h->add, dep[i], {func:dep[i], source:''}, /replace
  
  while ~s->isEmpty() do begin
     f = s->pop()
     f = f[0]
     
     if r->iscontained(f) then continue
     r->add, f, 1

     entry = h->get(f)
     
     if entry.source ne '' then continue
     
     ;- guess at file
     file = (file_which(f+'.pro'))[0]

     if ~file_test(file) then continue
     dep = finddep_file(file, count, definition = d, defct = dct)
     assert, size(dep, /type) eq 7

     if count ne 0 then s->push, dep
     for i = 0, count - 1, 1 do begin
        if h->iscontained(dep[i]) then continue
        h->add, dep[i], {func:dep[i], source:''}, /replace
     endfor

     for i = 0, dct - 1, 1 do $
        h->add, d[i], {func:d[i], source:file}, /replace
  endwhile
  
  obj_destroy, [s, r]
  k = h->keys()
  ct = h->count()
  if ct eq 0 then begin
     obj_destroy, h
     return, rec
  endif

  result = replicate(rec, n_elements(k))
  for i = 0, n_elements(k)-1 do result[i] = h->get(k[i])

  obj_destroy, h

  s = sort(result.func)
  result = result[s]
  if keyword_set(only_source) then begin
     good = where(result.source ne '', good_ct)
     if good_ct ne 0 then result = result[good] $
     else result = rec
  endif
  if keyword_set(no_source) then begin
     good = where(result.source eq '', good_ct)
     if good_ct ne 0 then result = result[good] $
     else result = rec
  endif
     
  return, result
end
     
pro test

  d = finddep_all('finddep_all.pro')
  s = sort(d.func)
  d = d[s]
  for i = 0, n_elements(d) - 1, 1 do begin
     p = strsplit(d[i].source, '/', /extract)
     p = p[n_elements(p)-1]
     print, d[i].func, p, format='(a15, 5x, a25)'
  endfor
end
