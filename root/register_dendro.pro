function register_dendro, ptr, ref, matrix = matrix, $
                          mask_matrix = mask_matrix

  if not array_equal((*ptr).szdata, (*ref).szdata) then $
     message, 'Dendrogram image sizes are incompatible'

  nst = n_elements((*ptr).height)
  nst_ref = n_elements((*ref).height)

  matrix = replicate(!values.f_nan, nst_ref, nst)
  mask_matrix = matrix

  cube = dendro2cube(ptr)
  rcube = dendro2cube(ref)
  indc = long(cube * 0 - 1)
  indr = long(rcube * 0 - 1)

  indc[(*ptr).x, (*ptr).y] = (*ptr).cluster_label
  indr[(*ref).x, (*ref).y] = (*ref).cluster_label

  ;- pre-calculate fluxes and sizes of reference structures
  fluxes_r = fltarr(nst_ref)
  sizes_r = fltarr(nst_ref)
  for i = 0, nst_ref - 1, 1 do begin
     ind = substruct(i, ref)
     fluxes_r = total( (*ref).t[ind])
     sizes_r = n_elements(ind)
  endfor

  for i = 0, nst - 1, 1 do begin
     ind = substruct(i, ptr)
     x = (*ptr).x[ind]
     y = (*ptr).y[ind]
     flux = total( (*ptr).t[ind] )

     rid = indr[x, y]
     h = histogram(rid, min = 0, rev = ri)
     for j = 0, n_elements(h) - 1, 1 do begin
        if h[j] eq 0 then continue
        rind = ri[ri[j] : ri[j + 1] - 1]        
        flux_r = total(rcube[rind])
        sim2 = flux_r * (*ptr).t[rind] / fluxes_r[j] / flux
        mask2 = n_elements(rind) / sqrt(n_elements(ind) * sizes_r[j])
        matrix[j, i] = sqrt(sim2)
        mask_matrix[j, i] = sqrt(mask2)
     endfor
  endfor
     
  ;- find best match for each structure
  rec = { id:0L, match:0L, $
          similarity:nan }

  best = max(matrix, loc, dim = 1, /nan)
  in = array_indices(matrix, loc)
  loc = reform(in[0,*])
  assert, n_elements(best) eq nst

  data = replicate(rec, nst)
  data.id = indgen(nst)
  data.match = loc
  data.similarity = best
  
  return, data
  
end     
