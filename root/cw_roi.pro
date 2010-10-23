function cw_roi_event, event

  ;- get the state information
  child = widget_info(event.handler, /child)
  widget_control, child, get_uvalue = state, /no_copy

  ;- event came from the drawcube widget. Get correct state
  if tag_names(state, /s) eq 'STATE_WIDGET' then begin
     widget_control, child, set_uvalue = state
     child = state.id
     widget_control, child, get_uvalue = state, /no_copy
     if n_elements(state) ne 0 then stop
     help, state
  endif

  ;- update state and maskinformation
  switch event.id of
     state.draw->getID() : begin
        state.x = event.x
        state.y = event.y
        state.z = event.z
     end
     hi:
     lo:
     open:
     seed:
     plane:
     do3:
     dx:
     dy:
     dz: begin
        cw_roi_calc_mask, state
        cw_roi_draw_masks, state
     end
     else:
  endswitch

  ;- display the mask  
  cw_roi_draw_masks, state

  ;- commit new mask
  widget_control, state.roi, get_value = roi_id
  case event.id of
     state.up_and: (*(state.masks))[roi_id] = (*(state.masks)) and *(state.mask)
     state.up_or: (*(state.masks))[roi_id] = (*(state.masks)) or *(state.mask)
     state.up_andnot: (*(state.masks))[roi_id] = (*(state.masks)) and not *(state.mask)
     else:
  endcase

  ;- save masks
  if event.id eq state.save then begin
     file = dialog_pickfile(/write, /overwrite_prompt, $
                            default_extension='sav', filter='*sav')
     outmask = state.masks
     save, outmask, file=file
  endif
  if event.id eq state.open_file then begin
     file = dialog_pickfile(/read, filter='*.sav')
     restore, file
     ptr_free, self.masks
     self.masks = outmask
  endif
  if event.id eq state.clear then *(state.mask) *= 0
  
  ;- update state info
  widget_control, child, set_uvalue = state, /no_copy

  ;- swallow the event
  return, 0
end

function cw_roi, parent, data, values = values, uvalue = uvalue
  compile_opt idl2

  tlb = widget_base(parent, col = 1, pro_set_value='roi_set_value', $
                    func_get_value='roi_get_value', $
                    event_func='cw_roi_event')

  tlb1 = widget_base(group_leader = tlb, event_func='cw_roi_event')
  widget_control, tlb1, /realize
 
  draw = cw_drawcube(tlb1, data)
  dobj = obj_new('drawcube', id = draw)
  rois = widget_droplist(tlb, value = values)
  
  sec1 = widget_base(tlb, column = 2)
  sec1_l = widget_base(sec1, column = 1)
  sec1_r = widget_base(sec1, row = 1)


  ;-hi, lo, open threshholds
  wid = 60
  wid_txt = 7
  row1 = widget_base(sec1_l, row = 1)
  lab1 = widget_label(row1, xsize = wid, value='Hi Thresh')
  hival = widget_text(row1, uvalue = 'hi', /edit, value = '1', xsize = wid_txt)

  row2 = widget_base(sec1_l, row = 1)
  lab2 = widget_label(row2, xsize = wid, value = 'Lo Thresh')
  loval = widget_text(row2, uvalue = 'lo', /edit, value='.5', xsize = wid_txt)
  
  row3 = widget_base(sec1_l, row = 1)
  lab3 = widget_label(row3, xsize = wid, value = 'Open')
  openval = widget_text(row3, uvalue='open', /edit, value='0', xsize = wid_txt)

  ;- use a seed or not
  lab4 = widget_label(sec1_r, value='Use Seed?')
  seed = widget_droplist(sec1_r, value = ['No', 'Yes'], uvalue = 'seed')

  ;-channel selectors
  sec2 = widget_base(tlb, column = 1)
  
  ;- update, save options
  sec3 = widget_base(tlb, column = 1)
  row1 = widget_base(sec3, row = 1)
  junk = widget_label(row1, value = 'Selection on:')
  planelist = widget_droplist(row1, value = ['XY', 'XZ', 'YZ', '3D'], uvalue= 'plane')
  
  junk = widget_label(sec3, value = 'Update:')
  row = widget_base(sec3, row = 1)
  b1 = widget_button(row, value = 'Intersect', uvalue='update_and')
  b2 = widget_button(row, value = 'Union', uvalue='update_or')
  b3 = widget_button(row, value = 'Subtract', uvalue='update_andnot')
  row = widget_base(sec3, row = 1)
  save = widget_button(row, value = 'Save...', uvalue = 'save')
  open = widget_button(row, value = 'Open...', uvalue = 'open_file')
  clear = widget_button(row, value = 'Reset', uvalue = 'clear')


  ;- 3D box selector widgets
  sec4 = widget_base(tlb, column = 1)
  lab = widget_droplist(sec4, value = ['No 3D box', '3D box'], uval = 'box')
  row1 = widget_base(sec4, row = 1)
  junk = widget_label(row1, value='x', xsize = wid)
  dx = widget_text(row1, uvalue='dx', value = '5', /edit)
 
  row2 = widget_base(sec4, row = 1)
  junk = widget_label(row2, value='y', xsize = wid)
  dy = widget_text(row1, uvalue='dy', value = '5', /edit)
  
  row3 = widget_base(sec4, row = 1)  
  junk = widget_label(row3, value='z', xsize = wid)
  dz = widget_text(row1, uvalue='dz', value = '5', /edit)
  
  ;- state structure
  state = { draw: dobj, roi:rois, hi:hival, lo:loval, open:openval, $
            seed:seed, plane:planelist, up_and:b1, up_or:b2, up_andnot:b3, $
            save:save, open_file:open, clear:clear, do3:lab, $
            dx:dx, dy:dy, dz:dz, x:0, y:0, z:0 }

  ;- this must go to children of BOTH tlb and tlb1
  child = widget_info(tlb, /child)
  widget_control, child, set_uvalue = state
  old_child = child
  child = widget_info(tlb1, /child)
  widget_control, child, set_uvalue = {state_widget, id:old_child}

  return, tlb
end

pro test
  data = fltarr(256, 256, 256)
  indices, data, x, y, z
  x -= 128 & y -= 128 & z -= 128
  data = sin(sqrt(x^2 + y^2 +z^2) / 30)
  
  tlb = widget_base(col = 1)
  values = ['1','2','3']
  roi = cw_roi(tlb, data, values = values)
  widget_control, tlb, /realize
  xmanager, 'test', tlb
end
