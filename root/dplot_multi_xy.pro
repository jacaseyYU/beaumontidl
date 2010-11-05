function dplot_multi_xy, ids, ptr, leaf =leaf, norm = norm
  clusters = (*ptr).clusters
  if keyword_set(norm) then begin
     height = 1. * cluster_height(clusters)
  endif else height = (*ptr).height
  xloc = (*ptr).xlocation

  xs = obj_new('stack')
  ys = obj_new('stack')
  for i = 0, n_elements(ids) - 1, 1 do begin
     id = ids[i]
     partner = merger_partner(id, clusters, merge=m)
     hasPartner = (partner ne -1)
     if ~hasPartner then continue
     hi = height[id]
     lo = height[m]
     if ~keyword_set(leaf) then begin
        xs->push, [xloc[id], xloc[id], xloc[m], !values.f_nan]
        ys->push, [hi, lo, lo, !values.f_nan]
     endif else begin
        xs->push, [xloc[id], xloc[id], !values.f_nan]
        ys->push, [hi, lo, !values.f_nan]
     endelse
  endfor
  x = xs->toArray()
  y = ys->toArray()
  obj_destroy, [xs, ys]
  return, transpose([[x],[y]])
end
