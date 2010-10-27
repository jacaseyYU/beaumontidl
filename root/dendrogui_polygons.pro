function dendrogui_polygons, state, _extra = extra

  nmask = 8
  ptr = state.ptr
  for i = 0, nmask - 1, 1 do begin
     print, 'mask ', i, state.id[i]
     ;- mask unused
     if state.id[i] eq -1 then continue
     ;- mask traces leaves
     if state.id[i] eq -2 then $
        ids = get_leaves((*ptr).clusters) $
     else $
        ids = leafward_mergers(state.id[i], (*ptr).clusters)
     print, ids
     ;-loop through substructures, aggregate mask pixels
     sx = obj_new('stack') & sy = obj_new('stack') & sz = obj_new('stack')
     for j = 0, n_elements(ids) - 1, 1 do begin
        id = ids[j]
        if (*ptr).cluster_label_h[id] eq 0 then continue
        ind = (*ptr).cluster_label_ri[ (*ptr).cluster_label_ri[id] : $
                                       (*ptr).cluster_label_ri[id+1]-1]
        sx->push, (*ptr).x[ind]
        sy->push, (*ptr).y[ind]
        sz->push, (*ptr).v[ind]
     endfor
     x = sx->toArray() & y = sy->toArray() & z = sz->toArray()
     obj_destroy, [sx, sy, sz]

     ;- convert points into a cube
     lo = [min(x, max=mx), min(y, max=my), min(z, max=mz)]
     hi = [mx, my, mz]
     range = hi - lo
     x -= lo[0] & y -= lo[1] & z -= lo[2]
     cube = fltarr(range[0], range[1], range[2])
     cube[x, y, z] = 1

     ;- cube to surface
     isosurface, cube, 1, v, c
     v = mesh_smooth(v, c)
     v[0,*] += lo[0] & v[1,*] += lo[1] & v[2,*] += lo[2]
     
     ;- surface to polygon
     o = obj_new('idlgrpolygon', v, poly = c, color = state.subplot_colors[*,i], _extra = extra)
     result = append(result, o)
  endfor ;- done loop over masks
  help, result
  return, n_elements(result) eq 0 ? obj_new() : result
end

