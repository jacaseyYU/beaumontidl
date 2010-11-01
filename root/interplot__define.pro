pro interplot_event, event
  widget_control, event.top, get_uval = state
  if tag_names(event, /struct) ne 'INTERWIN_EVENT' then $
     state->redraw
end

pro interplot::set_data, data
  nd = n_elements(data)
  nd_old = n_element(*self.data)
  *self.data = data
  if nd ne nd_old then *self.subset_id = replicate(0, nd)
end

pro interplot::set_subset_id, subset, index
  if n_elements(index) ne 0 then $
     (*self.subset_id)[index] = subset $
  else $
     (*self.subset_id)[0] = subset
  self->redraw
end

pro interplot::set_subset_properties, subset, index
  self.subsets[index] = subset
end

function interpolot::get_subset_properties, index, all = all
  on_error, 2
  if ~keyword_set(all) && n_elements(index) eq 0 then $
     message, 'Must provide an index, or set the /all keyword'
  if keyword_set(all) then return, self.subsets
  return, self.subsets[index]
end

pro interplot::assign_subset, subset_id, index
  if n_elements(index) eq 0 then $
     *self.subset_id[0] = subset_id $
  else $
     *self.subset_id[index] = subset_id
end

function interplot::get_subset_id
  return, *self.subset_id
end

pro interplot::cleanup
  ptr_free, [self.data, self.subset_id, $
             self.interwin]
end

pro interplot::setplotvar, plotindex, varindex
  widget_control, self.varlists[plotindex], $
                  set_value = varindex
  self->redraw
end

function interplot::init, data, subset = subset, $
                          subset_id = subset_id, $
                          plotvar1 = plotvar1, $
                          plotvar2 = plotvar2

  if ~keyword_set(plotvar1) then plotvar1 = 0
  if ~keyword_set(plotvar2) then plotvar2 = 0

  tlb = widget_base(/column)


  if ~keyword_set(subset) then begin
     sub = self.subsets
     sub.symsize = 1
     sub.linestyle = 0
     sub.alpha = 1
     sub.color = transpose(fsc_color(['black', 'blue', 'crimson', 'green', $
                                      'teal', 'purple', 'orange', 'brown'], /triple))
     self.subsets = sub
     for i = 0, n_elements(sub) - 1, 1 do begin
        s = obj_new('idlgrsymbol', 0, size = sub[i].symsize, $
                    color = sub[i].color, alpha = sub[i].alpha, thick = 3)
        temp = self.subsets[i]
        temp.symbol = s
        self.subsets[i] = temp
     endfor
  endif
  for i = 0, 4, 1 do help, (self.subsets[i]).symbol
  s = self.subsets[1]
  s.linestyle = 6
  s.symbol->setProperty, data = 1, size=.2
  self.subsets[1] = s

  if ~keyword_set(subset_id) then self.subset_id = ptr_new(replicate(0, n_elements(data)), /no_copy)
  model = obj_new('idlgrmodel')
  help, self.subsets[0], /struct
  print, (self.subsets[0]).color
  self.plotobj[0] = obj_new('idlgrplot', data.(0), data.(1), $
                            _extra = self.subsets[0])
  model->add, self.plotobj[0]


  self.interwin = obj_new('interwin', model, tlb)

  base2 = widget_base(tlb, col = 1)
  r1 = widget_base(base2, /row)
  r2 = widget_base(base2, /row)
  tags = tag_names(data)
  lab1 = widget_label(r1, value='Variable 1')
  list1 = widget_droplist(r1, value = tags)
  lab2 = widget_label(r2, value='Variable 2')
  list2 = widget_droplist(r2, value = tags)
  widget_control, list2, set_droplist_select = 1
  
  self.tlb = tlb
  self.data = ptr_new(data)
  self.varlists=[list1, list2]
  self.model = model

  return, 1
end

pro interplot::redraw
  ;- get variables to plot
  x = widget_info(self.varlists[0], /droplist_select)
  y = widget_info(self.varlists[1], /droplist_select)
  x = (*self.data).(x)
  y = (*self.data).(y)

  ;- plot them
  for i = 0, n_elements(self.plotobj) - 1, 1 do begin
     hit = where(*self.subset_id eq i, ct)
     if ct eq 0 then continue
     if obj_valid(self.plotobj[i]) then $
        self.plotobj[i]->setProperty, datax = x[hit], datay = y[hit] $
     else begin
        print, i, self.subsets[i]
        self.plotobj[i] = obj_new('idlgrplot', x[hit], y[hit], _extra = self.subsets[i])
        self.model->add, self.plotobj[i]
     endelse
                                      
  endfor
  self.interwin->request_redraw
end                          

pro interplot::run
  widget_control, self.tlb, /realize, set_uvalue = self
  xmanager, 'interplot', self.tlb, /no_block
  self->redraw
end

pro interplot__define
  data = { interplot, $
           data:ptr_new(), $
           subsets:replicate({subset}, 8), $
           subset_id:ptr_new(), $
           interwin:obj_new(), $
           model:obj_new(), $
           plotobj:objarr(8), $
           plotvar1:0, $
           plotvar2:0, $

           tlb:0L, $
           varlists: lonarr(2) $

         }
end
           

pro test
  data=replicate({x:0., y:0.,z:0.}, 5000)
  data.x = arrgen(-10, 10, nstep = 5000)
  data.y = sin(data.x)/data.x
  data.z = cos(data.x)
  o = obj_new('interplot', data)
  o->run
  o->set_subset_id, replicate(1, 2500), indgen(2500)
end
  
