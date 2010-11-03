function dplot_obj, ptr, id, norm = norm, _extra = extra
  result = dplot_xy(ptr, id, norm = norm)
  return, obj_new('idlgrplot', result[0,*], result[1,*], _extra = extra)
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
