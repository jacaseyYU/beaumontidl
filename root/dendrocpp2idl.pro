function dendrocpp2idl, file
  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, 'result = dendrocpp2idl(file)'
     return, !vaues.f_nan
  endif

  if size(file, /type) ne 7 then $
     message, 'file must be a string'

  if ~file_test(file) then $
     message, 'file not found: '+file

  im =mrdfits(file, 0, h,/silent)
  id =mrdfits(file, 1, h,/silent)
  clusters = mrdfits(file, 2, h,/silent)
  seeds = reform(mrdfits(file, 3, h, /silent))

  cv = dendrocpp2cloudviz(file)
  
  ci = lindgen(n_elements((*cv).value))
  sz = size(im)
  ind = lindgen(n_elements(im))
  x = ind mod sz[1]
  y = (ind / sz[1]) mod sz[2]
  v = (sz[0] eq 3) ? (ind / (sz[1] * sz[2])) : ind*0

  st = {$
       t:(*cv).value, $
       clusters: (*cv).clusters, $
       cluster_label: (*cv).cluster_label, $
       cluster_label_h: (*cv).cluster_label_h, $
       cluster_label_ri: (*cv).cluster_label_ri, $
       xlocation: (*cv).xlocation, $
       height: (*cv).height, $
       cubeindex: ci, $
       x:x, y:y, v:v, $
       szdata: size(im), $
       seeds: seeds $
       }

  ptr_free, cv
  return, ptr_new(st, /no_copy)
end
