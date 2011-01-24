pro dendrogui_event, event
  type = tag_names(event, /struct)
  widget_control, event.top, get_uvalue = sptr
  widget_control, event.id, get_uvalue = uval
  
  ;- handle events generated from clients
  client = strmatch(type, 'DG_*')
  if client then begin

     ;- dendroplot, slice events are 
     ;- ignored when click-dragging
     if type eq 'DG_DENDROPLOT_EVENT' || $
        type eq 'DG_SLICE_EVENT' then begin
        dendrogui_check_listen, event, sptr
     endif
     
     kbrd_ev = contains_tag(event, 'TYPE') && $
        contains_tag(event, 'RELEASE') && $
        (event.type eq 5 || event.type eq 6) && event.release
     mouse_ev = ~kbrd_ev && contains_tag(event, 'TYPE') && $
        (event.type eq 1 || event.type eq 0 || event.type eq 2)

     if mouse_ev && contains_tag(event, 'SUBSTRUCT') then $
        dendrogui_substruct_event, event, sptr
     
     if kbrd_ev then dendrogui_keyboard_event, event, sptr
     
     dendrogui_sync_clients, sptr
     return
  endif
  
  ;- handle events from the dendrogui panel
  tlb = event.top
  data = (*sptr).data
  ptr = (*sptr).ptr
  color = (*sptr).color
  alpha = (*sptr).alpha
  case uval of
     'select': dendrogui_maskselect_event, event, sptr
     'color': dendrogui_color_event, event, sptr
     'ddb': begin
        match = (*sptr).clients->get(/all, isa = 'dg_dendroplot', count = ct)
        if ct eq 1 then break
        assert, ct eq 0
        dd = obj_new('dg_dendroplot', ptr, group_leader = tlb, color = color, $
                     listen = tlb, xoffset = 200, $
                     alpha = alpha)
        dd->run
        (*sptr).clients->add, dd
        dendrogui_sync_clients, sptr
     end
     'dpb': begin
        if ~ptr_valid(data) then break
        dp = obj_new('dg_interplot', ptr, *data, group_leader = tlb, color = color, $
                             listen = tlb, xoffset = 200, alpha = alpha)
        dp->run
        (*sptr).clients->add, dp
        dendrogui_sync_clients, sptr
     end
     'dsb': begin
        match = (*sptr).clients->get(/all, isa = 'dg_slice', count = ct)
        if ct eq 1 then break
        assert, ct eq 0
        ds = obj_new('dg_slice', ptr, group_leader = tlb, color = color, $
                     listen = tlb, xoffset = 200, $
                     alpha = alpha)
        ds->run
        (*sptr).clients->add, ds
        dendrogui_sync_clients, sptr
     end
     'dib': begin
        match = (*sptr).clients->get(/all, isa = 'dg_iso', count = ct)
        for i = 0, ct - 1 do if obj_class(match[i]) ne 'DG_ISO' then ct--
        if ct eq 0 then begin
           di = obj_new('dg_iso', ptr, group_leader = tlb, $
                                color = color, listen = tlb, xoffset = 200, $
                                alpha = alpha)
           di->run
           (*sptr).clients->add, di
        endif
        dendrogui_sync_clients, sptr, /force, /iso
     end
     else:
  endcase
end

pro dendrogui_cleanup, tlb
  widget_control, tlb, get_uvalue = sptr
  ptr_free, (*sptr).data, (*sptr).substructs
  obj_destroy, (*sptr).clients
  ptr_free, sptr
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
     'S': (*sptr).dosingle = ~((*sptr).dosingle)
     'P': begin
        ptr = (*sptr).ptr
        id = (*sptr).substructs[(*sptr).index] & id = *id
        if max(id) lt 0 then return
        dendro_pivot, max(id), ptr
        dendrogui_sync_clients, sptr, /pivot
     end
     'L': dendrogui_set_substruct, get_leaves((*(*sptr).ptr).clusters), sptr
     'D' : begin
        if ~(*sptr).haveDual then break
        cs = (*sptr).clients->get(/All, isa = 'dg_iso_dual', count = ct)
        if ct eq 0 then begin
           obj = obj_new('dg_iso_dual', (*sptr).ptr, *(*sptr).vel, *(*sptr).vgrid)
           obj->run
           (*sptr).clients->add, obj
        endif
        dendrogui_sync_clients, sptr, /iso
     end
        
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
  id = (*sptr).substructs[(*sptr).index] & id  = *id
  ptr = (*sptr).ptr

  parents = leafward_mergers(max(id), (*ptr).clusters, /parent)
  partner = merger_partner(max(id), (*ptr).clusters, merge = child)
  if keyword_set(left) || keyword_set(right) then begin
     if parents[0] eq -1 then return
     l = parents[0] & r = parents[1]
     if (*ptr).xlocation[l] gt (*ptr).xlocation[r] then swap, l, r
     if keyword_set(left) then sub_id = l
     if keyword_set(right) then sub_id = r
     sub_id = leafward_mergers(sub_id, (*ptr).clusters)
  endif
  if keyword_set(down) && partner ne -1 then begin
     sub_id = leafward_mergers(child, (*ptr).clusters)
  endif
  
  *((*sptr).substructs[(*sptr).index]) = sub_id
end


pro dendrogui_substruct_event, event, sptr
  name = tag_names(event, /struct)
  if (name eq 'DG_DENDROPLOT_EVENT' || $
     name eq 'DG_SLICE_EVENT') && ~(*sptr).listen then return
  if contains_tag(event, 'self') then begin
     sub = event.self->calc_substruct(event)
     event.substruct = sub
  endif

  ;- convert the provided event substruct into a resolved list of 
  ;- substruct ids

  if size(event.substruct, /tname) eq 'POINTER' then begin
     substruct = *event.substruct
     ptr_free, event.substruct
  endif else substruct = event.substruct

  ;- any window except interplot selects this structure
  ;- plus substructs
  ptr = (*sptr).ptr
  plotSubs = ~((*sptr).dosingle) && ~strmatch(name, 'DG_INTER*', /fold)
  if plotSubs then begin
     assert, n_elements(substruct) eq 1
     substruct = leafward_mergers(substruct, (*ptr).clusters)
  endif
  dendrogui_set_substruct, substruct, sptr
end

pro dendrogui_check_listen, event, sptr
  if event.LEFT_CLICK || event.RIGHT_CLICK then begin
     (*sptr).old_listen = (*sptr).listen
     (*sptr).listen = 0
  endif
  if event.LEFT_DRAG then (*sptr).drag = 1B
  if event.LEFT_RELEASE then begin
     if (*sptr).drag then (*sptr).listen = (*sptr).old_listen
     if ~(*sptr).drag then (*sptr).listen = ~(*sptr).old_listen
     (*sptr).drag = 0
  endif
  if event.RIGHT_RELEASE then begin
     (*sptr).listen = (*sptr).old_listen
  endif
end

pro dendrogui_set_id, id, sptr
  widget_control, (*sptr).selects[(*sptr).index], set_value = (*sptr).uncheck_bmp
  widget_control, (*sptr).selects[id], set_value = (*sptr).check_bmp
  (*sptr).index = id
  
  cs = (*sptr).clients->get(/all, count = ct)
  for i = 0, ct - 1, 1 do cs[i]->set_current, id
end

pro dendrogui_sync_clients, sptr, iso = iso, force = force, pivot = pivot
  if keyword_set(iso) then widget_control, /hourglass

  cs = (*sptr).clients->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(cs[i]) then continue
     doForce = keyword_set(force) || $
               (obj_isa(cs[i], 'dg_dendroplot') && keyword_set(pivot) ) || $
               (obj_isa(cs[i], 'dg_iso') && keyword_set(iso))
     for j = 0, 7, 1 do begin
        cs[i]->set_substruct, j, *(*sptr).substructs[j], force = doForce
     endfor
     if (obj_isa(cs[i], 'dg_dendroplot') && keyword_set(pivot)) then $
        cs[i]->redraw_baseplot
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
  ;- pick a new color
  
  ;- update the proper mask
  for i = 0, 7 do if event.id eq (*sptr).colors[i] then break
  assert, i lt 8

  old = (*sptr).color[*,i]
  new = cnb_pickcolor(/brewer, cancel = cancel, $
                     red = old[0], green=old[1], blue=old[2], $
                      alpha=(*sptr).alpha[i])
  if cancel then return

  (*sptr).color[*,i] = new[0:2]
  (*sptr).alpha[i] = new[3]

  widget_control, (*sptr).colors[i], $
                  set_value = rebin(reform(byte(new[0:2]), 1,1,3), 20, 20, 3)
                                                   
  cs = (*sptr).clients->get(/all, count = ct)
  for j = 0, ct - 1, 1 do $
     cs[j]->set_color, i, new[0:2], alpha = new[3]
  dendrogui_sync_clients, sptr, /force

end


pro dendrogui, ptr, data = data, vel = vel, vgrid = vgrid

;  restore, '~/dendro/ex_ptr_small.sav'
  if n_elements(ptr) eq 0 then begin
     print, 'Calling sequence'
     print, ' dendrogui, ptr, [data = data]'
     return
  end

  if ~contains_tag(*ptr, 'CLUSTER_LABEL_H') then begin
     message, /info, 'Pointer is out of date. Updating and overwriting'
     ptr = update_topo(ptr)
  endif

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
  
  dd->run

  clients = obj_new('idl_container')
  clients->add, dd
  
  if keyword_set(vel) then begin
     if ~keyword_set(vgrid) then $
        message, 'vgrid must be provided if vel is'
     have_Dual = 1
     state_vel = ptr_new(vel)
     state_vgrid = ptr_new(vgrid)
  endif else begin
     state_vel = ptr_new()
     state_vgrid = ptr_new()
     have_Dual = 0
  endelse
     
  substructs = ptrarr(8)
  alpha = replicate(.7, 8)
  for i = 0, 7 do substructs[i] = ptr_new(-10)
  state={rows:rows, selects:selects, colors:colors, $
         index:0, uncheck_bmp:check, check_bmp:red_check, $
         clients: clients, $
         substructs:substructs, ptr:ptr, $
         dosingle:0, $
         data:n_elements(data) ne 0 ? ptr_new(data) : ptr_new(), $
         color:color, alpha:alpha, $
         listen:1, old_listen:0, drag:0, $
         vel: state_vel, vgrid:state_vgrid, haveDual : have_Dual}
  sptr = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue = sptr
  widget_control, tlb, /realize

  xmanager, 'dendrogui', tlb, cleanup='dendrogui_cleanup', /no_block
end
