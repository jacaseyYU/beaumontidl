;+
; PURPOSE:
;  This function converts a pointer generated from TOPOLOGIZE to one
;  that can be used by cloudviz and dendroviz. 
;
; INPUTS:
;  ptr: A pointer to a dendrogram structure created by topologize
;
; OUTPUTS:
;  A new pointer that can be fed directly to cloudviz and dendroviz
;  routines
;
; MODIFICATION HISTORY:
;  Jan 2011: Written by Chris Beaumont
;-
function dendro2cloudviz, ptr
  
  compile_opt idl2
  on_error, 2

  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, 'result = dendro2cloudviz(ptr)'
     return, !values.f_nan
  endif

  cube = dendro2cube(ptr)
  label = long(cube*0)-1
  label[(*ptr).x, (*ptr).y, (*ptr).v] = (*ptr).cluster_label
  h = histogram(label, min = 0, rev = ri)
  st = {$
       value: cube, $
       clusters:(*ptr).clusters, $
       cluster_label:label, $
       cluster_label_h: h, $
       cluster_label_ri:ri, $
       xlocation:(*ptr).xlocation, $
       height:(*ptr).height $
       }
  result = ptr_new(st, /no_copy)
  return, result
end
