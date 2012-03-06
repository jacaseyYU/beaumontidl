pro recursive_plot_xyz, id, xs, ys, zs, clusters, height, xloc, yloc
  nleaf = n_elements(clusters[0,*])+1
  partner = merger_partner(id, clusters, merge=m)
  isLeaf = id lt nleaf
  hi = height[id]
  lo = partner eq -1 ? height[id] : height[m]

  if isLeaf then begin
     xs->push, [xloc[id], xloc[id]]
     ys->push, [yloc[id], yloc[id]]
     zs->push, [hi, lo]
     return
  endif
  
  leafwards = clusters[*, id-nleaf]
  
  xs->push, [xloc[id], xloc[leafwards[0]]]
  ys->push, [yloc[id], yloc[leafwards[0]]]
  zs->push, [hi, hi]
  recursive_plot_xyz, leafwards[0], xs, ys, zs, clusters, height, xloc, yloc
  
  xs->push, xloc[leafwards[1]]
  ys->push, yloc[leafwards[1]]
  zs->push, hi
  recursive_plot_xyz, leafwards[1], xs, ys, zs, clusters, height, xloc, yloc

  xs->push, [xloc[id], xloc[id]]
  ys->push, [yloc[id], yloc[id]]
  zs->push, [hi, lo]
end


function dplot_xyz, ptr, id, yloc, norm = norm
  compile_opt idl2

  clusters = (*ptr).clusters
  if keyword_set(norm) then begin
     height = 1. * cluster_height(clusters)
  endif else height = (*ptr).height
  xloc = (*ptr).xlocation

  nobj = n_elements(height)
  visited = bytarr(nobj)

  start = n_elements(id) eq 0 ? max(clusters)+1 : id

  xs = obj_new('stack') & ys = obj_new('stack') & zs = obj_new('stack')
  partner = merger_partner(start, clusters, merge = m)
  lo = partner eq -1 ? height[start] : height[m]

  xs->push, xloc[start] & ys->push, yloc[start] & zs->push, lo
  recursive_plot_xyz, start, xs, ys, zs, clusters, height, xloc, yloc
  ax = xs->toArray() & obj_destroy, xs
  ay = ys->toArray() & obj_destroy, ys
  az = zs->toArray() & obj_destroy, zs
  return, transpose([[ax], [ay], [az]])
end
