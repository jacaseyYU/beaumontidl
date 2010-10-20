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

  return
end

function dplot_obj, ptr, id, _extra = extra

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
  return, obj_new('idlgrplot', ax, ay, _extra = extra)
end

pro test_event, event
  widget_control, event.top, get_uval = info
  branch = pick_branch(event.x, event.y, (*ptr).xlocation, (*ptr).height, (*ptr).clusters)
  if branch eq info.branch then return
  

  new_plot = dplot_obj(ptr, branch, color = [255,0,0], thick=2)


  info.view->remove, info.select
  obj_destroy, info.select
  info.view->add, new_plot, pos = 0

  info.branch = branch
  info.select = new_plot

;  widget_control, info.win, get_value = wid
;  wid->draw, info.view

  widget_control, event.top, set_uval = info
end

pro test
;  common test, ptr
  if n_elements(ptr) eq 0 then restore, 'ex_ptr_small.sav'

  cubify, (*ptr).x, (*ptr).y, (*ptr).v, (*ptr).t, $
          cube = minicube
  cube = ptr_new(minicube, /no_copy)

;  clusters=[[0,1], $
;            [2,3], $
;            [4,6], $
;            [5,7]]
;  height = [10, 9, 11, 8, 7, 6, 5, 4, 2]
;  xloc=[1, 3, 7, 9, 5, 2, 8, 6, 4]
;  ptr = ptr_new({clusters:clusters, height:height, xlocation:xloc})

  model = dplot_obj(ptr)
  
  tlb = widget_base()
  tlb2 = widget_base()
  ;drawcube = obj_new('drawcube', *cube, tlb2)

  xra = minmax((*ptr).xlocation)
  xra += .05 * range(xra) * [-1, 1]
  yra = minmax((*ptr).height)
  yra += .05 * range(yra) * [-1, 1]
  draw = pzplot(tlb, model, xrange=xra, yra = yra, view=view)

  widget_control, tlb, /realize
  widget_control, tlb2, /realize

  info = {ptr:ptr, branch:-1L, select:obj_new(), $
          model:model, view:view, win:draw, cube:cube}

  widget_control, tlb, set_uvalue = info

  xmanager, 'test', tlb, /no_block
  xmanager, 'test', tlb2
  ptr_free, ptr
  help, /heap

end
