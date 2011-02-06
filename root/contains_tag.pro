function contains_tag, struct, tag
  if n_params() ne 2 then begin
     print, 'calling sequence:'
     print, 'result = contains_tag(struct, tag)'
     return,!values.f_nan
  endif

  if n_elements(struct) ne 1 then $
     message, 'argument must be a scalar'

  if size(struct, /type) ne 8 then return, 0

  names = tag_names(struct)
  hit = where(strmatch(names, tag, /fold), ct)
  return, ct ne 0
end
  
