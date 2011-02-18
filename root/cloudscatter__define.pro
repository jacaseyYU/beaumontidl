function cloudscatter::event, event
  widget_control, event.id, get_uvalue = uval
  self->resizePoints
  super = self->roiwin::event(event)
  if size(super, /TNAME) eq 'STRUCT' then $
     self.hub->receiveEvent, super

  self->updateAxes
  
  ;- change line thickness
  if event.id eq self.mbar && $
     strmatch(event.value, 'Plot.Line Thickness*') then $
        self->setLineThickness, event.value

  ;- change point size
  if event.id eq self.mbar && $
     strmatch(event.value, 'Plot.Point Size*') then $
        self->setPointSize, event.value


  ;- changing plot variables
  isStr = size(uval, /tname) eq 'STRING'
  if isStr && uval eq 'list' $
  then self->updatePlots, /recenter

  ;- toggle line connection
  if contains_tag(event, 'TYPE') && $
     event.type eq 5 && event.release && strupcase(event.ch) eq 'C' then $
     self->toggleConnect

  ;- updated roi
  if size(super, /tname) eq 'STRUCT' && $
     tag_names(super, /struct) eq 'ROI_EVENT' then begin
     self.protectROI = 1B
     substructs = self->roi2substructs(count = ct)
     self.hub->setCurrentStructure, substructs
  endif

  ;- log button events
  if isStr && uval eq 'log1' then self->toggleLog, /xlog
  if isStr && uval eq 'log2' then self->toggleLog, /ylog

  return, 1
end

pro cloudscatter::notifyStructure, index, structure, force = force
  self->updatePlots
;  self->updateSubplot, index
end

pro cloudscatter::notifyCurrent, id
  self->reset_roi
end

pro cloudscatter::notifyColor, index, color
  self->updateSubplot, index
end

pro cloudscatter::run
  self->interwin::run
end

pro cloudscatter::setLineThickness, thickness
  case thickness of
     'Plot.Line Thickness.1': th = 1
     'Plot.Line Thickness.2': th = 2
     'Plot.Line Thickness.3': th = 3
     'Plot.Line Thickness.4': th = 4
     else:
  endcase

  self.baseplot->setProperty, thick = th
  for i = 0, n_elements(self.subplots) -1 do $
     if obj_valid(self.subplots[i]) then self.subplots[i]->setProperty, thick=th
  self->updatePlots
end

pro cloudscatter::connectLines, x, y, rootwards = rootwards
  ptr = self.hub->getData()
  nst = n_elements((*ptr).cluster_label_h)
  nleaf = n_elements( (*ptr).clusters) / 2 + nleaf
  parents = intarr(nst)
  id = indgen( n_elements( (*ptr).clusters ) / 2 ) + nleaf
  parents[ (*ptr).clusters ] = id
  rootwards = parents
  newx = reform(transpose([[x], [x[parents]], [x*!values.f_nan]]))
  newy = reform(transpose([[y], [y[parents]], [y*!values.f_nan]]))
  x = newx
  y = newy
end

pro cloudscatter::setPointSize, size
  ;- code is 'Plot.Point Size.[0-5]'
  sz = strsplit(size, '.', /extract)
  sz = fix(sz[n_elements(sz)-1])
  self.pt_sz = sz
  self->resizePoints
end

pro cloudscatter::updatePlots, recenter = recenter
  eold = !except
  !except = 0

  if ~self.protectROI then self->reset_roi else $
     self.protectROI = 0

  ;- update plot data
  xid = widget_info(self.varlists[0], /droplist_select)
  yid = widget_info(self.varlists[1], /droplist_select)
  tags = tag_names( *self.data )
  self.axtitle[0]->setProperty, strings = tags[xid]
  self.axtitle[1]->setProperty, strings = tags[yid]
  x = (*self.data).(xid)
  y = (*self.data).(yid)
  if self.xlog then x = alog10(x)
  if self.ylog then y = alog10(y)

  if self.connect then self->connectLines, x, y, rootwards = rootwards
  self.baseplot->setProperty, datax = x, datay = y

  
  for i = 0, 7, 1 do self->updateSubplot, i
  if keyword_set(recenter) then self->recenter

  self->request_redraw
  !except = eold
end

pro cloudscatter::recenter
  self->reset_roi
  self.baseplot->getProperty, data = data
  xra = minmax(data[0,*], /nan)
  yra = minmax(data[1,*], /nan)
  xbad = range(xra) eq 0 || total(finite(xra)) eq 0
  ybad = range(yra) eq 0 || total(finite(yra)) eq 0

  if xbad then xra=[0,1]
  if ybad then yra=[0,1]

  xra += .16 * range(xra) * [-1,1]
  yra += .16 * range(yra) * [-1,1]
  self.view_cen = [mean(xra), mean(yra)]
  self.view_wid = [range(xra), range(yra)]
  tags = tag_names((*self.data))
  self->update_viewplane
  self->resizePoints
  self->updateAxes
  self->request_redraw
end

pro cloudscatter::updateSubplot, index
  s = self.hub->getStructure(index)
  self.baseplot->getProperty, data = data

  ;- get the data points
  if min(s) lt 0 then begin
     x = [!values.f_nan]
     y = [!values.f_nan]
  endif else begin
     if self.connect then begin
        ;- for connected plots, points are [base, rootward, nan]
        ss = transpose([ [3 * s], [3 * s+1], [3 * s+2] ])
        ss = reform(ss, n_elements(ss))
        x = data[0, ss]
        y = data[1, ss]
     endif else begin
        x = data[0,s]
        y = data[1,s]
     endelse
  endelse

  ;- update the plot
  color = self.hub->getColors(index)
  assert, obj_valid(self.subplots[index])

  self.subplots[index]->getProperty, symbol = s
  s->setProperty, color = color[0:2], alpha = 1;color[3]/255.
  self.subplots[index]->setProperty, datax = [x], datay = [y]
     

  self->request_redraw
end

pro cloudscatter::updateAxes
  eold = !except
  !except = 0

  cen = self.view_cen
  wid = self.view_wid
  g = widget_info(self.draw, /geom)

  loc = cen - .39 * wid
  xra = [cen[0]-.39*wid[0], cen[0]+.45*wid[0]]
  yra = [cen[1]-.39*wid[1], cen[1]+.45*wid[1]]

  xra_ax = (-1d300) > (self.xlog ? 10D^xra : xra) < (1d300)
  yra_ax = (-1d300) > (self.ylog ? 10D^yra : yra) < (1d300)
  self.axes[0]->setProperty, location=loc, range=xra_ax, ticklen = .03 * wid[1], /exact
  self.axes[1]->setProperty, location=loc, range=yra_ax, ticklen = .03 * wid[0], /exact
  self.axes[0]->getProperty, ticktext=t1
  self.axes[1]->getProperty, ticktext=t2

  ;- text has 1:1 aspect ratio in pixel coords.
  xsc = wid[0] / g.xsize
  ysc = wid[1] / g.ysize

  csz = .03 * wid * [1 > g.ysize / g.xsize, 1 > g.xsize / g.ysize]
  t1->setProperty, char_dim=csz
  t2->setProperty, char_dim=csz

  self.axtitle[0]->setProperty, char_dim = csz
  self.axtitle[1]->setProperty, char_dim = csz[[1,0]]
  
  self.basePlot->setProperty, xrange=xra, yrange=yra
  for i = 0, n_elements(self.subplots)-1 do $
     if obj_valid(self.subplots[i]) then $
        self.subplots[i]->setProperty, xra = xra, yra = yra
  !except = eold   
end

pro cloudscatter::resizePoints
  wid = self.view_wid
  g = widget_info(self.draw, /geom)
  sz = self.pt_sz * wid / (g.xsize > g.ysize)
  self.baseplot->getProperty, symbol = s

  s->setProperty, size=sz

  for i = 0, 7, 1 do begin
     if ~obj_valid(self.subplots[i]) then continue
     self.subplots[i]->getProperty, symbol = s
     s->setProperty, size=sz
  endfor
  self->request_redraw
end


pro cloudscatter::toggleLog, xlog = xlog, ylog = ylog
  if keyword_set(xlog) then self.xlog = ~self.xlog
  if keyword_set(ylog) then self.ylog = ~self.ylog
  self.axes[0]->setProperty, log = self.xlog
  self.axes[1]->setProperty, log = self.ylog
  self->updatePlots, /recenter
end


function cloudscatter::roi2substructs, count = count
  self.baseplot->getProperty, data = d
  count = 0

  if n_elements(d) eq 0 || total(finite(d)) eq 0 then $
     return, 0
  if self.connect then begin
     ;- every third item, starting with zero, is a unique point
     ;- the next two points are its parent and nan
     nd = n_elements(d[0,*])
     d = d[*, indgen(nd/3)*3]
  endif
  hit = self.roi->containsPoints(d[0,*], d[1,*])
  return, where(hit, count)
end


pro cloudscatter::resize, x, y
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


pro cloudscatter::cleanup
  self->interwin::cleanup
  self->cloudviz_client::cleanup
  ptr_free, self.data
  obj_destroy, [self.baseplot, self.subplots, self.axes, self.axtitle]
end


function cloudscatter::init, hub, data

  if ~self->cloudviz_client::init(hub) then return, 0
  if size(data, /type) ne 8 then $
     message, 'data must be a structure!'

  tags = tag_names(data)
  if n_elements(tags) lt 2 then $
     message, 'data must have 2 or more structure tags!'
  self.data = ptr_new(data)

  ;- create all the plot objects
  self.pt_sz = 4
  symbol = obj_new('idlgrsymbol', 4, thick = 3)
  plot = obj_new('idlgrplot', $
                 data.(0), data.(1), symbol = symbol, linestyle = 6)
  
  for i = 0, 7, 1 do begin
     self.subplots[i] = obj_new('idlgrplot', $
                                [!values.f_nan], $
                                [!values.f_nan], $
                                symbol = obj_new('idlgrsymbol', 4, thick = 3), $
                                linestyle = 6 )
  endfor

  self.axtitle=[obj_new('idlgrtext', tags[0]), $
                obj_new('idlgrtext', tags[1])]

  xra = minmax(data.(0), /nan)
  yra = minmax(data.(1), /nan)

  xaxis = obj_new('idlgraxis', 0, title=self.axtitle[0])
  yaxis = obj_new('idlgraxis', 1, title=self.axtitle[1])
  self.axes = [xaxis, yaxis]

  model = obj_new('idlgrmodel')
  model->add, xaxis
  model->add, yaxis
  model->add, plot
  for i = 0, n_elements(self.subplots) -1 do model->add, self.subplots[i], pos = 2

  self.baseplot = plot
  
  if ~self->roiwin::init(model, title='Scatter Plot') then return, 0
  self.widget_base = self.base

  ;- extra widgets for selecting plot variables
  base2 = widget_base(self.base, col = 1)
  self.base2 = base2
  r1 = widget_base(base2, /row)
  r2 = widget_base(base2, /row)
  lab1 = widget_label(r1, value='X')
  list1 = widget_droplist(r1, value = tags, uval='list')
  log1 = widget_button(r1, value='Log', uval='log1')
  lab2 = widget_label(r2, value='Y')
  list2 = widget_droplist(r2, value = tags, uval='list')
  log2 = widget_button(r2, value='Log', uval='log2')
  widget_control, list2, set_droplist_select = 1

  ;- extra menu buttons
  menu_desc = ['1\Plot', $
               '1\Line Thickness', $
               '0\1', $
               '0\2', $
               '0\3', $
               '2\4', $
               '1\Point Size', $
               '0\0', $
               '0\1', $
               '0\2', $
               '0\3', $
               '0\4', $
               '0\5']
  plotbutton = cw_pdmenu(self.mbar, menu_desc, /mbar, /return_full_name)
  self.varlists = [list1, list2]

  return, 1
end

pro cloudscatter__define

  data = {cloudscatter, $
          inherits cloudviz_client, $
          inherits roiwin, $
          base2:0L, $
          data:ptr_new(), $
          varlists:[0L, 0L], $
          baseplot:obj_new(), $
          subplots:objarr(8), $
          axes:objarr(2), $
          axtitle:objarr(2), $
          xlog:0B, $
          ylog:0B, $
          protectROI:0B, $
          connect:0B, $
          pt_sz:0 $          
         }
end
