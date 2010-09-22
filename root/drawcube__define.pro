function drawcube::getID
  return, self.id
end


function drawcube::getData, pointer = pointer
  widget_control, self.id, get_value = result
  return, keyword_set(pointer) ? result :  *result
end


pro drawcube::redraw, mask = mask, _extra = extra
  ;- get the state
  child = widget_info(self.id, /child)
  widget_control, child, get_uvalue = state
  drawcube_update_widgets, state, mask = mask, $
                           _extra = extra
end


pro drawcube::cleanup
  widget_control, self.id, /destroy, bad = bad
end

function drawcube::init, data, parent, uvalue = uvalue, id = id
  if n_params() ne 2 && ~keyword_set(id) then begin
     print, 'calling sequence:'
     print, " obj = obj_new('drawcube', parent, data, [uvalue= uvalue])"
     print, 'or'
     print, " obj = obj_new('drawcube', id = id)"
     return, 0
  endif
  if keyword_set(id) then begin
     self.id = id
     return, 1
  endif
  id = cw_drawcube(data, parent, uvalue = uvalue)
  self.id = id
  return, 1
end

pro drawcube__define
  data = {drawcube, id : 0L}
end

pro test_event, ev
end
  
pro test
  data = fltarr(256, 256, 256)
  indices, data, x, y, z
  x -= 128 & y -= 128 & z -= 128
  data = sin(sqrt(x^2 + y^2 +z^2) / 30)
  
  tlb = widget_base()
  dc = obj_new('drawcube', data, tlb)
  
  widget_control, tlb, /realize
  xmanager, 'test', tlb, /no_block
  dc->redraw, mask = (data gt .5), color = fsc_color('orange')
  wait, 5
  obj_destroy, dc
end

  
