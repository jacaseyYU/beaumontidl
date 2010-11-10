pro dg_dendroplot::redraw_baseplot
  ptr = self.ptr
  self.model->remove, self.baseplot
  obj_destroy, self.baseplot
  dendro = dplot_obj(ptr, max((*ptr).clusters+1))
  self.baseplot = dendro
  self.model->add, self.baseplot, pos = 0
  self->request_redraw
end

pro dg_dendroplot::set_substruct, index, substruct, force = force

  if ~keyword_set(force) && array_equal(substruct, *self.substructs[index]) then return
  *self.substructs[index] = substruct
  xy = (substruct[0] lt 0) ? replicate(!values.f_nan, 2, 2) : $
       dplot_multi_xy(substruct, self.ptr, norm = self.norm)

  if ~obj_valid(self.plots[index]) then begin
     plot = obj_new('idlgrplot', xy[0,*], xy[1,*], $
                    color =  self.colors[*,index], $
                    thick = 3)
     self.plots[index] = plot
     self->interwin::add_graphics_atom, plot, position = 0
  endif else begin
     self.plots[index]->setProperty, datax = xy[0,*], $
                                             datay = xy[1,*], $
                                             color = self.colors[*,index], $
                                             alpha = self.alpha[index] > 1., $
                                             thick = 3
     ;- send object to front
     obj = self.model->get(/all)
     nobj = n_elements(obj)
     self.model->remove, self.plots[index]
     self.model->add, self.plots[index], position=nobj-1
  endelse
  self.redraw = 1
end

pro dg_dendroplot::update_info, text
  if strmid(text, 0, 2) ne 'ID' then return
  widget_control, self.label, set_value = text
end

function dg_dendroplot::event, event
  
  ;- handle basic interwin events
  super = self->interwin::event(event)

  ;- super is a struct if interwin generated a draw event
  relay = size(super, /tname) eq 'STRUCT'
  if ~relay then return, 0

  ;- catch 'N' press, normalize denroplots
  if event.type eq 5 && event.release && strupcase(event.ch) eq 'N' then $
     self->toggle_normplots

  ;- find the structure we're looking at, and 
  ;- send information to client
  x = super.x & y = super.y
  substruct = pick_branch(x, y, (*self.ptr).xlocation, $
                          (*self.ptr).height, (*self.ptr).clusters)
  info = create_struct(super, 'substruct', substruct, $
                       name = 'dg_dendroplot_event')
  if self.listener gt 0 then $
     widget_control, self.listener, send_event = info
  
  self->update_info, string(substruct, format='("ID: ", i0)')
  return, 0
     
end
  
pro dg_dendroplot::toggle_normplots
  self.norm = ~self.norm
  ptr = self.ptr
  dendro = dplot_obj(ptr, max((*ptr).clusters+1), norm = self.norm)
  self.model->remove, self.baseplot
  obj_destroy, self.baseplot
  self.baseplot = dendro
  self.model->add, dendro

  for i = 0, 7 do self->set_substruct, i, *self.substructs[i],  /force
end

function dg_dendroplot::init, ptr, color = color, $
                              alpha = alpha, $
                              listener = listener, $
                              _extra = extra
  
  junk = self->dg_client::init(ptr, listener, color = color, alpha = alpha)
  dendro = dplot_obj(ptr, max((*ptr).clusters+1))
  self.baseplot = dendro
  yra = minmax((*ptr).height) + range((*ptr).height) * [-.05, .05]
  axis = obj_new('idlgraxis', direction = 1, range = yra)
  model = obj_new('IDLgrModel', /depth_test_disable)
  model->add, dendro
  model->add, axis

  return, self->interwin::init(model, _extra = extra, title='Dendrogram')


  return, 1
end

pro dg_dendroplot::cleanup
  self->interwin::cleanup
  self->dg_client::cleanup
  obj_destroy, [self.plots, self.baseplot]
end

pro dg_dendroplot__define
  data = { dg_dendroplot, inherits interwin, $
           inherits dg_client, $
           baseplot:obj_new(), $
           plots:objarr(8), $
           norm:0B}
end


pro test_event, event
  widget_control, event.top, get_uvalue = obj
  obj->set_substruct, randomu(seed)*5, [event.substruct, floor(randomu(seed,3)*50)]
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

