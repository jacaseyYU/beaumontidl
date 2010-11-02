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

pro dg_interplot::update_axes
  ;- axes 7% in from the left/bottom
  cen = self.view_cen
  wid = self.view_wid
  loc = cen - .39 * wid
  xra = [cen[0]-.39*wid[0], cen[0]+.45*wid[0]]
  yra = [cen[1]-.39*wid[1], cen[1]+.45*wid[1]]
  self.axes[0]->setProperty, location=loc, range=xra, ticklen = .03 * wid[1], /exact
  self.axes[1]->setProperty, location=loc, range=yra, ticklen = .03 * wid[0], /exact
  self.axes[0]->getProperty, ticktext=t1
  self.axes[1]->getProperty, ticktext=t2
  t1->setProperty, char_dim=.02*wid
  t2->setProperty, char_dim=.02*wid

  self.axtitle[0]->setProperty, char_dim = .02 * wid 
  self.axtitle[1]->setProperty, char_dim = .02 * wid[[1,0]]
  
  self.basePlot->setProperty, xrange=xra, yrange=yra
  for i = 0, n_elements(self.subplots)-1 do $
     self.subplots[i]->setProperty, xra = xra, yra = yra
   
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
  self->update_axes
  if size(uval, /tname) eq 'STRING' && uval eq 'list' $
  then self->update_plots, /snap
  if size(super, /tname) eq 'STRUCT' && $
  super.LEFT_CLICK eq 0 then help, super, /struct
  return, 1
end

function dg__interplot::update_roi, event
  self.roi->appendData, event.x, even.ty
  ;- draw roi to image
  self.roi->getProperty, data = vert
  self.roiplot->setProperty, data = vert
  ;- which points are inside?
  self.baseplot->getProperty, data = pts
  inside = self.roi->containsPoints(pts)
  return, where(inside)
end

pro dg_interplot::clear_roi
  self.roi->getProperty, data = d
  nvert = n_elements(d)/2
  self.roi->removeData, count = nvert
  self.roiplot->setProperty, data=[[!values.f_nan], [!values.f_nan]]
end

pro dg_interplot::update_plots, snap = snap
  xid = widget_info(self.varlists[0], /droplist_select)
  yid = widget_info(self.varlists[1], /droplist_select)
  x = (*self.data).(xid)
  y = (*self.data).(yid)
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
        self->add_graphics_atom, self.subplots[i], position = 2
     endelse
  endfor

  ;- resize viewplane if changing plot variables
  if keyword_set(snap) then begin
     xra = minmax(x,/nan) & yra = minmax(y,/nan)
     print, xra, yra
     xbad = range(xra) eq 0 || min(~finite(xra))
     ybad = range(yra) eq 0 || min(~finite(yra))
     
     if xbad then xra=[0,1]
     if ybad then yra=[0,1]

     xra += .15 * range(xra) * [-1,1]
     yra += .15 * range(yra) * [-1,1]
     self.view_cen = [mean(xra), mean(yra)]
     self.view_wid = [range(xra), range(yra)] * 1.05
     tags = tag_names(*self.data)
     print, tags[[xid, yid]]
     self.axtitle[0]->setProperty, strings=tags[xid]
     self.axtitle[1]->setProperty, strings=tags[yid]
     self->update_viewplane
     self->resize_points
     self->update_axes
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
  tags = tag_names(data)

  symbol = obj_new('idlgrsymbol', 4, thick=3)
  plot = obj_new('idlgrplot', $
                 data.(0), $
                 data.(1), symbol = symbol, linestyl=6)
  self.data = ptr_new(data)

  self.axtitle=[obj_new('idlgrtext', tags[0]), $
                obj_new('idlgrtext', tags[1])]
  xaxis = obj_new('idlgraxis', 0, range=minmax(data.(0)), title=self.axtitle[0])
  yaxis = obj_new('idlgraxis', 1, range=minmax(data.(1)), title=self.axtitle[1])
  self.axes=[xaxis, yaxis]

  model = obj_new('idlgrmodel')
  model->add, xaxis
  model->add, yaxis
  model->add, plot
  
  self.baseplot = plot
  junk = self->interwin::init(model, _extra = extra)
  
  ;- extra widgets for selecting plot variables
  base2 = widget_base(self.base, col = 1)
  self.base2 = base2
  r1 = widget_base(base2, /row)
  r2 = widget_base(base2, /row)
  lab1 = widget_label(r1, value='Variable 1')
  list1 = widget_droplist(r1, value = tags, uval='list')
  lab2 = widget_label(r2, value='Variable 2')
  list2 = widget_droplist(r2, value = tags, uval='list')
  widget_control, list2, set_droplist_select = 1

  self.varlists = [list1, list2]
  nan = !values.f_nan
  self.roiplot = obj_new('idlgrplot', [nan,nan],[nan,nan])
  self.model->add, roiplot
  self.roi = obj_new('idlanroi')
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
          roiplot:obj_new(), $
          roi:obj_new(), $
          axes:objarr(2), $
          axtitle:objarr(2), $
          data:ptr_new()}

end
