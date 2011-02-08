function dendro2cloudviz, ptr
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
