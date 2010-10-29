pro dg_dendroplot::set_substruct, index, substruct
  
  case 1 of
     substruct eq -1 : xy = leafplot_xy(self.ptr)
     substruct ge 0: xy = dplot_xy(self.ptr, substruct)
     else: xy=replicate(!values.f_nan, 2, 2)
  endcase

  if ~obj_valid(self.plots[index]) then begin
     plot = obj_new('idlgrplot', xy[0,*], xy[1,*], $
                    color =  self.colors[*,index], $
                    thick = 2)
     self.plots[index] = plot
     self->pzwin::add_graphics_atom, plot
  endif else begin
     self.plots[index]->setProperty, datax = xy[0,*], $
                                             datay = xy[1,*]
  endelse
end
  
function dg_dendroplot::event, event

  ;- handle basic pzwin events
  res = self->pzwin::event(event)


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

  if relay && self.dg_has_listen then begin
     print, 'sending result'
     widget_control, self.dg_listen, send_event = result
  endif

  return, result

end

function dg_dendroplot::init, ptr, color = color, $
                              widget_listener = widget_listener, $
                              _extra = extra

  dendro = dplot_obj(ptr, max((*ptr).clusters+1))
  yra = minmax((*ptr).height) + range((*ptr).height) * [-.05, .05]
  axis = obj_new('idlgraxis', direction = 1, range = yra)
  model = obj_new('IDLgrModel')
  model->add, dendro

  if ~keyword_set(color) then $
     color = transpose(fsc_color(['crimson', 'royalblue', 'orange', 'purple', $
                                  'yellow', 'teal', 'brown', 'green'], /triple))


  self.color = color
  self.ptr = ptr
  
  help, widget_listener
  if keyword_set(widget_listener) then begin
     self.dg_has_listen = 1B
     self.dg_listen = widget_listener
  endif

  return, self->pzwin::init(model, _extra = extra)


  return, 1
end

pro dg_dendroplot::cleanup
  self->pzwin::cleanup
  obj_destroy, [self.plots]
end

pro dg_dendroplot__define
  data = { dg_dendroplot, inherits pzwin, $
           plots:objarr(8), $
           color:bytarr(3,8), $
           ptr:ptr_new(), $
           dg_has_listen: 0B, $
           dg_listen:0L}
end


pro test_event, event
  help, event
end
pro test
  restore, '~/dendro/ex_ptr_small.sav'
  tlb = widget_base()
  widget_control, tlb, /realize
  xmanager, 'test', tlb, /no_block
  dp = obj_new('dg_dendroplot', ptr, widget_listen = tlb)
  dp->run
end

