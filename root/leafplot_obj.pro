function leafplot_obj, ptr, _extra = extra

  leaves = get_leaves((*ptr).clusters)
  clusters = (*ptr).clusters
  height = (*ptr).height
  xloc = (*ptr).xlocation

  xs = obj_new('stack')
  ys = obj_new('stack')
  for i = 0, n_elements(leaves) - 1, 1 do begin
     id = leaves[i]
     partner = merger_partner(id, clusters, merge=m)
     assert, partner ne -1
     hi = height[id]
     lo = height[m]
     xs->push, [xloc[id], xloc[id], !values.f_nan]
     ys->push, [hi, lo, !values.f_nan]
  endfor
  x = xs->toArray()
  y = ys->toArray()
  obj_destroy, [xs, ys]
  return, obj_new('idlgrplot', x, y, _extra = extra)
end
