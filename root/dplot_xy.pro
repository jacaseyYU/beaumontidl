pro recursive_plot, id, xs, ys, clusters, height, xloc
  nleaf = n_elements(clusters[0,*])+1
  partner = merger_partner(id, clusters, merge=m)
  isLeaf = id lt nleaf
  hi = height[id]
  lo = partner eq -1 ? min(height) - .05 * range(height) : height[m]
  

  if isLeaf then begin
     xs->push, [xloc[id], xloc[id]]
     ys->push, [hi, lo]
     return
  endif
  
  leafwards = clusters[*, id-nleaf]
  
  xs->push, [xloc[id], xloc[leafwards[0]]]
  ys->push, [hi, hi]
  recursive_plot, leafwards[0], xs, ys, clusters, height, xloc
  
  xs->push, xloc[leafwards[1]]
  ys->push, hi
  recursive_plot, leafwards[1], xs, ys, clusters, height, xloc

  xs->push, [xloc[id], xloc[id]]
  ys->push, [hi, lo]
end


function dplot_xy, ptr, id
  clusters = (*ptr).clusters
  height = (*ptr).height
  xloc = (*ptr).xlocation

  nobj = n_elements(height)
  visited = bytarr(nobj)

  start = n_elements(id) eq 0 ? max(clusters)+1 : id

  xs = obj_new('stack') & ys = obj_new('stack')
  partner = merger_partner(start, clusters, merge = m)
  lo = partner eq -1 ? height[0]*0 : height[m]

  xs->push, xloc[start] & ys->push, lo
  recursive_plot, start, xs, ys, clusters, height, xloc
  ax = xs->toArray() & obj_destroy, xs
  ay = ys->toArray() & obj_destroy, ys
  return, transpose([[ax], [ay]])
end
