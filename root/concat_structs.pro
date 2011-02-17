function concat_structs, s1, s2, names = names
  if n_params() ne 2 then begin
     print, 'calling sequence'
     print, 'result = concat_structs(s1, s2, names = names)'
  endif

  if size(s1, /type) ne 8 || size(s2, /type) ne 8 then $
     message, 's1 and s2 must be structure scalars or arrays'

  t1 = tag_names(s1)
  t2 = tag_names(s2)

  if ~keyword_set(names) then names = [t1, t2]

  if n_elements(names) ne n_elements(t1) + n_elements(t2) then $
     message, 'Number of names provided does not match size of catalog'
  
  if size(names, /type) ne 7 then $
     message, 'names must be a string array'

  num = n_elements(s1)
  if n_elements(s2) ne num then $
     message, 'Structure arrays must be the same length'

  
  
