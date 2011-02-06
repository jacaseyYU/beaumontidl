pro dg
  
  restore, '~/dendro/ex_ptr_small.sav'
  cube = dendro2cube(ptr)
  label = long(cube*0)-1
  label[(*ptr).x, (*ptr).y, (*ptr).v] = (*ptr).cluster_label
  h = histogram(label, min = 0, rev = ri)
  st = {$
       value: cube, $
       clusters:(*ptr).clusters, $
       cluster_label:label, $
       cluster_label_h: h, $
       cluster_label_ri:ri, $
       xlocation:(*ptr).xlocation, $
       height:(*ptr).height $
       }
  ptr_free, ptr
  ptr = ptr_new(st, /no_copy)
  hub = obj_new('cloudviz_hub', ptr)
  panel = obj_new('cloudviz_panel', hub)
  plot = obj_new('dendroplot', hub)
  slice = obj_new('cloudslice', hub)
  listen = obj_new('dendroviz_listener', hub)
  iso = obj_new('cloudiso', hub)
  hub->add, panel
  hub->add, iso
  hub->add, plot
;  hub->add, slice
  hub->addListener, listen
  return
  
  if ~contains_tag(*ptr, 'CLUSTER_LABEL_H') then begin
     message, /info, 'Pointer is out of date. Updating and overwriting'
     ptr = update_topo(ptr)
  endif

  tlb = widget_base(/column)
  
  color = byte(transpose($
          fsc_color(['red', 'teal', 'orange', 'purple', 'yellow', $
                     'brown', 'royalblue', 'green'], /triple)) $
              )
  
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
         vel: state_vel, vgrid:state_vgrid, haveDual : have_Dual, $
         tlb:tlb}
  sptr = ptr_new(state, /no_copy)
  widget_control, tlb, set_uvalue = sptr
  widget_control, tlb, /realize

  xmanager, 'dendrogui', tlb, cleanup='dendrogui_cleanup', /no_block
end
