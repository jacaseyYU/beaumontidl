pro dendrogui_event, event
  type = tag_names(event, /struct)
  widget_control, event.top, get_uvalue = sptr
  
  ;- received an event from a client
  if type eq 'DG_DENDROPLOT_EVENT' || $
     type eq 'DG_SLICE_EVENT' then begin
     kbrd_ev = (event.type eq 5 || event.type eq 6) && event.release
     mouse_ev = event.type eq 1 || event.type eq 0 || event.type eq 2
     if kbrd_ev then dendrogui_keyboard_event, event, sptr $
     else if mouse_ev then dendrogui_substruct_event, event, sptr
     dendrogui_sync_clients, sptr
     return
  endif

  widget_control, event.top, get_uvalue = sptr
  widget_control, event.id, get_uvalue = uval

  tlb = event.top
  data = (*sptr).data
  ptr = (*sptr).ptr
  color = (*sptr).color
  case uval of
     'select': dendrogui_maskselect_event, event, sptr
     'color': dendrogui_color_event, event, sptr
     'ddb': begin
        if obj_valid((*sptr).dd) then break
        (*sptr).dd = obj_new('dg_dendroplot', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 200)
        (*sptr).dd->run
        dendrogui_sync_clients, sptr
     end
     'dpb': begin
        if obj_valid((*sptr).dp) then break
        if ~ptr_valid(data) then break
        (*sptr).dp = obj_new('dg_interplot', ptr, *data, group_leader = tlb, color = color, listen = tlb, xoffset = 200)
        (*sptr).dp->run
        dendrogui_sync_clients, sptr
     end
     'dsb': begin
        if obj_valid((*sptr).ds) then break
        (*sptr).ds = obj_new('dg_slice', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 200)
        restore, '~/perseus/catalogs/per_yso_model.sav'
        o = model->get(/all)
        model->remove, o[0]
        (*sptr).ds->add_graphics_atom, o[0]
        (*sptr).ds->run
        dendrogui_sync_clients, sptr
     end
     'dib': begin
        if obj_valid((*sptr).di) then break
        (*sptr).di = obj_new('dg_iso', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 200)
        (*sptr).di->run
        dendrogui_sync_clients, sptr, /iso
     end
     else:
  endcase
end

pro dendrogui_cleanup, tlb
  widget_control, tlb, get_uvalue = sptr
  ptr_free, (*sptr).data
  obj_destroy, [(*sptr).dd, (*sptr).dp, (*sptr).ds, (*sptr).di]
end

pro dendrogui_keyboard_event, event, sptr
  case strupcase(event.ch) of
     '0': dendrogui_set_id, 0, sptr
     '1': dendrogui_set_id, 1, sptr
     '2': dendrogui_set_id, 2, sptr
     '3': dendrogui_set_id, 3, sptr
     '4': dendrogui_set_id, 4, sptr
     '5': dendrogui_set_id, 5, sptr
     '6': dendrogui_set_id, 6, sptr
     '7': dendrogui_set_id, 7, sptr
     'X': dendrogui_set_substruct, -2, sptr
     'I': dendrogui_sync_clients, sptr, /iso
     'L': dendrogui_set_substruct, -1, sptr
     else:
  endcase
  LEFT = 5 & RIGHT = 6 & DOWN = 8
  case event.key of 
     LEFT: dendrogui_set_substruct, 0, sptr, /left
     RIGHT: dendrogui_set_substruct, 0, sptr, /right
     DOWN: dendrogui_set_substruct, 0, sptr, /down
     else:
  endcase
end

pro dendrogui_set_substruct, sub_id, sptr, left = left, right = right, down = down
  id = (*sptr).substructs[(*sptr).index]
  ptr = (*sptr).ptr
  parents = leafward_mergers(id, (*ptr).clusters, /parent)
  partner = merger_partner(id, (*ptr).clusters, merge = child)

  if keyword_set(left) || keyword_set(right) then begin
     if parents[0] eq -1 then return
     l = parents[0] & r = parents[1]
     if (*ptr).xlocation[l] gt (*ptr).xlocation[r] then swap, l, r
     if keyword_set(left) then sub_id = l
     if keyword_set(right) then sub_id = r
     (*sptr).substructs[(*sptr).index] = sub_id
     return
  endif
  if keyword_set(down) && partner ne -1 then begin
     (*sptr).substructs[(*sptr).index] = child
     return
  endif
     
  (*sptr).substructs[(*sptr).index] = sub_id
end


pro dendrogui_substruct_event, event, sptr
  dendrogui_set_substruct, event.substruct, sptr
end

pro dendrogui_set_id, id, sptr
  widget_control, (*sptr).selects[(*sptr).index], set_value = (*sptr).uncheck_bmp
  widget_control, (*sptr).selects[id], set_value = (*sptr).check_bmp
  (*sptr).index = id
  if obj_valid((*sptr).dp) then (*sptr).dp->set_current, id
  if obj_valid((*sptr).dd) then (*sptr).dd->set_current, id
  if obj_valid((*sptr).di) then (*sptr).di->set_current, id
  if obj_valid((*sptr).ds) then (*sptr).ds->set_current, id

end

pro dendrogui_sync_clients, sptr, iso = iso
  for i = 0, 7, 1 do begin
     if obj_valid((*sptr).dp) then $
        (*sptr).dp->set_substruct, i, (*sptr).substructs[i]
     if obj_valid((*sptr).ds) then $
        (*sptr).ds->set_substruct, i, (*sptr).substructs[i]
     if obj_valid((*sptr).di) && keyword_set(iso) then $
        (*sptr).di->set_substruct, i, (*sptr).substructs[i]
     if obj_valid((*sptr).dd) then $
        (*sptr).dd->set_substruct, i, (*sptr).substructs[i]
  endfor
end

pro dendrogui_maskselect_event, event, sptr
  ;- find out which id is the new id
  for i = 0, 7, 1 do begin
     if event.id eq (*sptr).selects[i] then break
  endfor
  assert, i lt 8
  dendrogui_set_id, i, sptr
end
  
pro dendrogui_color_event, event, sptr
end


pro dendrogui, ptr, data = data

;  restore, '~/dendro/ex_ptr_small.sav'
  if n_elements(ptr) eq 0 then begin
     print, 'Calling sequence'
     print, ' dendrogui, ptr, [data = data]'
     return
  end
  if n_elements(data) eq 0 then message, /info, 'No external data provided'
  tlb = widget_base(/column)
  
  color = byte(transpose(fsc_color(['red', 'teal', 'orange', 'purple', 'yellow', $
                               'brown', 'royalblue', 'green'], /triple)))

  ;- set up mask selector panel
  check = file_which('check.bmp')
  if ~file_test(check) then message, 'cannot find check.bmp'
  check = read_bmp(check)
  check = transpose(check, [1,2,0])
  red_check = check
  red_check[*,*,0]=255B
  check[*]= 255B

  rows = lonarr(8)
  selects = lonarr(8)
  colors = lonarr(8)
  for i = 0, 7, 1 do begin
     rows[i] = widget_base(tlb, /row)
     selects[i] = widget_button(rows[i], value=check, /bitmap, uvalue='select')
     colors[i] = widget_button(rows[i], value = rebin(reform(color[*, i], 1, 1, 3), 20, 20, 3), /bitmap, uvalue='color')
  endfor
  widget_control, selects[0], set_value=red_check

  ;- viz buttons
  row = widget_base(tlb, /row)
  ddb = widget_button(row, value='Dendro', uval='ddb')
  dpb = keyword_set(data) ? widget_button(row, value='Scatter', uval='dpb') : -1
  row2 = widget_base(tlb, /row)
  dsb = widget_button(row2, value='Slice', uvalue='dsb')
  dib = widget_button(row2, value='Iso', uvalue='dib')

  ;- initialize viz guis
  dd = obj_new('dg_dendroplot', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 200)
  dp = obj_new() & ds = obj_new() & di = obj_new()
;  dp = obj_new('dg_interplot', ptr, data, group_leader = tlb, color = color, listen = tlb, xoffset = 800)
;  ds = obj_new('dg_slice', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 200, yoffset = 200)
;  di = obj_new('dg_iso', ptr, group_leader = tlb, color = color, listen = tlb, xoffset = 400)
  
  dd->run
;  dp->run
;  ds->run
;  di->run

  state={rows:rows, selects:selects, colors:colors, $
         index:0, uncheck_bmp:check, check_bmp:red_check, $
         dd:dd, dp:dp, ds:ds, di:di, substructs:replicate(-2, 8), ptr:ptr, $
        data:n_elements(data) ne 0 ? ptr_new(data) : ptr_new(), color:color}
  sptr = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue = sptr
  widget_control, tlb, /realize

  xmanager, 'dendrogui', tlb, /no_block
end
