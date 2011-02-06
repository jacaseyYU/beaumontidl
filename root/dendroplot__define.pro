function dendroplot::event, event
  super = self->interwin::event(event)
  ;- if interwin didn't relay any events, 
  ;- there's nothing to do
  if size(super, /tname) ne 'STRUCT' then return, 0
  self.hub->receiveEvent, super

  if ~self.listener_toggle->check_listen(super) then return, 0

  if ~contains_tag(super, 'TYPE') || $
     (super.type ne 2) then return, 0
  
  x = super.x & y = super.y
  ptr = self.hub->getData()
  substruct = pick_branch(x, y, (*ptr).xlocation, $
                          (*ptr).height, (*ptr).clusters)

  self.hub->setCurrentStructure, leafward_mergers(substruct, (*ptr).clusters)

  self->update_info, string(substruct, format='("ID: ", i0)')

end

pro dendroplot::redraw_baseplot
  ptr = self.hub->getData()
  self.model->remove, self.baseplot
  obj_destroy, self.baseplot
  xy = dplot_xy(ptr, max((*ptr).clusters+1))
  self.baseplot = obj_new('idlgrplot', xy[0,*], xy[1,*])
  self.model->add, self.baseplot, pos = 0
  self->request_redraw
end


pro dendroplot::notifyStructure, index, structure, force = force
  xy = dplot_multi_xy(structure, self.hub->getData(), norm = self.norm)
  color = self.hub->getColors(index)

  if ~obj_valid(self.plots[index]) then begin
     plot = obj_new('idlgrplot', xy[0,*], xy[1,*], $
                    color =  color[0:2], $
                    thick = 3)
     self.plots[index] = plot
     nobj = self.model->count()
     self->interwin::add_graphics_atom, plot, position = nobj - 1
  endif else begin
     self.plots[index]->setProperty, $
        datax = xy[0,*], $
        datay = xy[1,*], $
        color = color[0:2], $
        thick = 3

     ;- send object to front
     nobj = self.model->count()
     self.model->remove, self.plots[index]
     self.model->add, self.plots[index], position=nobj-1
  endelse

  self->interwin::request_redraw
end

pro dendroplot::notifyColor, index, color
  if ~obj_valid(self.plots[index]) then return
  self.plots[index]->setProperty, color = color[0:2]
  self->request_redraw
end

pro dendroplot::notifyCurrent, id
  self.listener_toggle->set_listen, 0
end

pro dendroplot::update_info, text
  if strmid(text, 0, 2) ne 'ID' then return
  widget_control, self.label, set_value = text
end

pro dendroplot::toggle_normplots
  self.norm = ~self.norm
  ptr = self.hub->getData()
  xy = dplot_xy(ptr, max((*ptr).clusters+1), norm = self.norm)
  self.model->remove, self.baseplot
  obj_destroy, self.baseplot
  self.baseplot = obj_new('idlgrplot', xy[0,*], xy[1,*])
  self.model->add, dendro

  for i = 0, 7 do self->assignStructure, i, $
     self.hub->getStructure(i), /force
end


function dendroplot::init, hub, _extra = extra
  result = self->dendroviz_client::init(hub)
  if ~result then return, 0
  
  ptr = hub->getData()
  xy = dplot_xy(ptr, max((*ptr).clusters + 1))
  
  self.baseplot = obj_new('idlgrplot', xy[0,*], xy[1,*])
  yra = minmax((*ptr).height)

  axis = obj_new('idlgraxis', direction = 1, range = yra)
  model = obj_new('IDLgrModel', /depth_test_disable)
  model->add, self.baseplot
  model->add, axis

  self.listener_toggle = obj_new('listener_toggle')

  return, self->interwin::init(model, _extra = extra, title='Dendrogram')

end

pro dendroplot::run
  self->interwin::run
end

pro dendroplot::cleanup
  self->interwin::cleanup
  self->dendroviz_client::cleanup
  obj_destroy, [self.baseplot, self.plots, self.listener_toggle]
end

pro dendroplot__define
  data = {dendroplot, $
          inherits dendroviz_client, $
          inherits interwin, $
          baseplot:obj_new(), $
          plots:objarr(8), $
          norm:0B, $
          listener_toggle:obj_new() $
         }
end
