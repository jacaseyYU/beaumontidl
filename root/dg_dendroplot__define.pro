pro dg_dendroplot::set_substruct, index, substruct
  if ~self->dg_client::set_substruct(index, substruct) then return

  case 1 of
     substruct eq -1 : xy = leafplot_xy(self.ptr)
     substruct ge 0: xy = dplot_xy(self.ptr, substruct)
     else: xy=replicate(!values.f_nan, 2, 2)
  endcase

  if ~obj_valid(self.plots[index]) then begin
     plot = obj_new('idlgrplot', xy[0,*], xy[1,*], $
                    color =  self.colors[*,index], $
                    thick = 4)
     self.plots[index] = plot
     self->interwin::add_graphics_atom, plot
  endif else begin
     self.plots[index]->setProperty, datax = xy[0,*], $
                                             datay = xy[1,*]
  endelse
  self.redraw = 1
end
  
function dg_dendroplot::event, event

  ;- handle basic interwin events
  res = self->interwin::event(event)


  ;- determine which substruct we're pointing at
  relay = size(res, /tname) eq 'STRUCT'
  
  draw_event = relay && res.type eq 2
  
  substruct = -3
  if draw_event then begin
     x = res.x & y = res.y
     substruct = pick_branch(x, y, (*self.ptr).xlocation, $
                             (*self.ptr).height, (*self.ptr).clusters)
  endif 
  if relay then begin
     result = create_struct(res, 'substruct', substruct, $
                            name='dg_dp_draw')
  endif else begin
     result = create_struct('ID', event.handler, 'TOP', event.top, $
                            'HANDLER', event.handler, 'substruct', substruct, $
                            name='dg_dp_event')
  endelse

  if relay && self.listener gt 0 then begin
     widget_control, self.listener, send_event = result
  endif

  return, result

end

function dg_dendroplot::init, ptr, color = color, $
                              listener = listener, $
                              _extra = extra

  junk = self->dg_client::init(ptr, listener, color = color)
  dendro = dplot_obj(ptr, max((*ptr).clusters+1))

  yra = minmax((*ptr).height) + range((*ptr).height) * [-.05, .05]
  axis = obj_new('idlgraxis', direction = 1, range = yra)
  model = obj_new('IDLgrModel')
  model->add, dendro

  return, self->interwin::init(model, _extra = extra)


  return, 1
end

pro dg_dendroplot::cleanup
  self->interwin::cleanup
  obj_destroy, [self.plots]
end

pro dg_dendroplot__define
  data = { dg_dendroplot, inherits interwin, $
           inherits dg_client, $
           plots:objarr(8)}
end


pro test_event, event
  widget_control, event.top, get_uvalue = obj
  obj->set_substruct, randomu(seed)*5, event.substruct
  print, event.substruct
end

pro test
  restore, '~/dendro/ex_ptr_small.sav'
  tlb = widget_base()
  widget_control, tlb, /realize
  dp = obj_new('dg_dendroplot', ptr, listen = tlb)
  dp->run
  widget_control, tlb, set_uvalue = dp
  xmanager, 'test', tlb, /no_block

end

