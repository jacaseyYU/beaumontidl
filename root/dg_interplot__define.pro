pro dg_interplot::resize_points
  wid = self.view_wid
  self.baseplot->getProperty, symbol = s
  sz = .01 * wid
  s->setProperty, size=sz

  for i = 0, 7, 1 do begin
     if ~obj_valid(self.subplots[i]) then continue
     self.subplots[i]->getProperty, symbol = s
     s->setProperty, size=sz
  endfor
end

pro dg_interplot::set_substruct, id, substruct
  self->dg_client::set_substruct, id, substruct, status
  if ~status then return
  self->update_plots
end

function dg_interplot::event, event
  widget_control, event.id, get_uvalue = uval
  self->resize_points
  super = self->interwin::event(event)

  if size(uval, /tname) eq 'STRING' && uval eq 'list' $
  then self->update_plots, /snap
  
  return, 1
end

pro dg_interplot::update_plots, snap = snap
  x = widget_info(self.varlists[0], /droplist_select)
  y = widget_info(self.varlists[1], /droplist_select)
  x = (*self.data).(x)
  y = (*self.data).(y)
  self.baseplot->setProperty, datax = x, datay = y
  ptr = self.ptr
  for i = 0, 7, 1 do begin
     id = self.substructs[i]

     ;- what IDs belong to this substruct?
     if id eq -2 then ids = 0
     if id eq -1 then ids = get_leaves((*ptr).clusters)
     if id gt -1 then ids = leafward_mergers(id, (*ptr).clusters)
     if n_elements(ids) eq 0 then continue
     ids = [ids]

     dx = x[ids] & dy = y[ids]
     if id eq -2 then begin
        dx = [!values.f_nan]
        dy = [!values.f_nan]
     endif
     if obj_valid(self.subplots[i]) then begin
        self.subplots[i]->setProperty, datax = dx, datay = dy
     endif else begin
        self.subplots[i] = obj_new('idlgrplot', $
                                   dx, dy, $
                                   color = self.colors[*,i], $
                                   symbol = obj_new('idlgrsymbol', 4, thick=3), $
                                   linestyle = 6)
        self->add_graphics_atom, self.subplots[i], position = 0
     endelse
  endfor

  ;- resize viewplane
  if keyword_set(snap) then begin
     object_bounds, self.model, xra, yra, zra
     self.view_cen = [mean(xra), mean(yra)]
     self.view_wid = [range(xra), range(yra)] * 1.05
     self->update_viewplane
     self->resize_points
  endif

  self->request_redraw
end
     
pro dg_interplot::resize, x, y
  widget_control, self.base, update = 0

  b_g = widget_info(self.buttonbase, /geom)
  s_g = widget_info(self.base2, /geom)
  
  pad = 3.
  xnew = x - pad
  ynew =  y - b_g.ysize - s_g.ysize - 5*pad

  widget_control, self.buttonbase, xsize = xnew
  widget_control, self.draw, xsize = xnew, $
                  ysize = ynew
  widget_control, self.base2, xsize = xnew

  widget_control, self.base, update = 1
  self->request_redraw
end

function dg_interplot::init, ptr, $
                          data, $
                          color = color, $
                          listener = listener, $
                          _extra = extra

  junk = self->dg_client::init(ptr, listener, color = color)

  symbol = obj_new('idlgrsymbol', 4, thick=3)
  plot = obj_new('idlgrplot', $
                 data.(0), $
                 data.(1), symbol = symbol, linestyl=6)
  self.data = ptr_new(data)

  xaxis = obj_new('idlgraxis', 0, range=minmax(data.(0)))
  yaxis = obj_new('idlgraxis', 1, range=minmax(data.(1)))
  self.axes=[xaxis, yaxis]

  model = obj_new('idlgrmodel')
  model->add, plot
  model->add, xaxis
  model->add, yaxis
  
  self.baseplot = plot
  junk = self->interwin::init(model, _extra = extra)
  
  ;- extra widgets for selecting plot variables
  base2 = widget_base(self.base, col = 1)
  self.base2 = base2
  r1 = widget_base(base2, /row)
  r2 = widget_base(base2, /row)
  tags = tag_names(data)
  lab1 = widget_label(r1, value='Variable 1')
  list1 = widget_droplist(r1, value = tags, uval='list')
  lab2 = widget_label(r2, value='Variable 2')
  list2 = widget_droplist(r2, value = tags, uval='list')
  widget_control, list2, set_droplist_select = 1

  self.varlists = [list1, list2]
  return, 1
end

pro dg_interplot__define
  data = {dg_interplot, $
          inherits interwin, $
          inherits dg_client, $
          base2:0L, $
          varlists:[0L, 0L], $
          baseplot:obj_new(), $
          subplots:objarr(8), $
          axes:objarr(2), $
          data:ptr_new()}

end
