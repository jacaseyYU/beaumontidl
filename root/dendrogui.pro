pro dendrogui_event, event
  compile_opt idl2

  LEFT = 5 & RIGHT = 6 & DOWN = 8

  widget_control, event.top, get_uvalue = state
  drawid = state.draw->get_widget_id()

  ;- all image windows are closed. Exit program
  if ~obj_valid(state.z) then begin
     widget_control, event.top, /destroy
     return
  endif

  ;- resizing the top level base
  resizeEvent = event.id eq state.tlb && $
     tag_names(event, /struct) ne 'SLICE3_EVENT'

  if resizeEvent then begin
     g = widget_info(state.toprow, /geom)
     widget_control, state.bottomrow, $
                     scr_xsize = event.x, $
                     scr_ysize = event.y - g.scr_ysize
     widget_control, state.toprow, $
                     scr_xsize = event.x
     return
  endif

  menuEvent = event.id eq state.menu
  doListen = menuEvent ? 0 : dendro_check_listen(event, state)
  keyboardEvent = ~menuEvent && (event.key ne 0 || event.ch ne 0)
  imEvent = tag_names(event, /struct) eq 'SLICE3_EVENT'

  ;- toggle leaf plotting with "L" key?
  if keyboardEvent && $
     event.ch ne 0 && $
     ((event.ch eq byte('L')) or (event.ch eq byte('l'))) && $
     event.release $
  then toggle_leafplot, state

  ;- selecting a new structure with mouse?
  if ~menuEvent && ~keyboardEvent && doListen then begin
     if imEvent then begin
        ptr = state.ptr
        hit = where((*ptr).x eq floor(event.x) and $
                    (*ptr).y eq floor(event.y) and $
                    (*ptr).v eq floor(event.z), ct)
        id = (ct eq 0) ? -1 : (*ptr).cluster_label[hit[0]]
     endif else id = pick_branch(event.x, event.y, (*state.ptr).xlocation, $
                                 (*state.ptr).height, (*state.ptr).clusters)
     dendro_update_mask, state, id
  endif
  
  ;-changing mask color?
  if event.id eq state.menu then begin
     state.mask_id = event.value-1
     state.listen = 1
  endif

  ;-using arrow keys to step around dendro?
  if ~menuEvent && event.key ne 0 && event.release then begin
     ptr = state.ptr
     id = state.id[state.mask_id]
     partner = merger_partner(id, (*ptr).clusters, merge = child)
     parents = leafward_mergers(id, (*ptr).clusters, /parent)
     if parents[0] ne -1 then begin
        l = parents[0] & r = parents[1]
        if (*ptr).xlocation[l] gt (*ptr).xlocation[r] then swap, l, r
        if event.key eq LEFT then dendro_update_mask, state, l
        if event.key eq RIGHT then dendro_update_mask, state, r
     endif        
     if event.key eq DOWN && partner ne -1 then dendro_update_mask, state, child
  endif
        
  if state.id[state.mask_id] gt 0 then $
     widget_control, state.label, set_value=string(state.id[state.mask_id], $
                                                   (*state.ptr).height[state.id[state.mask_id]], format='(i4, 2x, e0.2)')
  widget_control, event.top, set_uvalue = state
end


function dendro_check_listen, event, state
  if event.LEFT_CLICK || event.RIGHT_CLICK then begin
     state.old_listen = state.listen
     state.listen = 0
  endif
  if event.LEFT_DRAG then state.drag = 1B
  if event.LEFT_RELEASE then begin
     if state.drag then state.listen = state.old_listen
     if ~state.drag then state.listen = ~state.old_listen
     state.drag = 0
  endif
  if event.RIGHT_RELEASE then begin
     state.listen = state.old_listen
  endif
  return, state.listen
end

pro toggle_leafplot, state
  ;- clear out current mask
  *state.mask and= not ishft(1, state.mask_id)

  ;- are we already showing leaves?
  if state.leaf_id ne -1 then begin
     *state.mask and= (not ishft(1, state.leaf_id))
     state.model->remove, state.subplot[state.leaf_id]
     obj_destroy, state.subplot[state.leaf_id]

     state.leaf_id = -1
     subplot = obj_new()
  endif else begin
     state.leaf_id = state.mask_id

     ;- clear out current color
     *state.mask and= not ishft(1, state.leaf_id)

     ;- create leaf mask
     ids = get_leaves((*state.ptr).clusters)
     ptr = state.ptr
     for i = 0, n_elements(ids) - 1, 1 do begin
        ind = ids[i]
        if ind lt 0 || ind ge n_elements((*ptr).cluster_label_h) then continue
        if (*ptr).cluster_label_h[ind] eq 0 then continue
        ind = (*ptr).cluster_label_ri[(*ptr).cluster_label_ri[ind] : $
                                      (*ptr).cluster_label_ri[ind+1]-1]
        (*state.mask)[(*ptr).x[ind], (*ptr).y[ind], (*ptr).v[ind]] or= ishft(1, state.leaf_id)
     endfor
     subplot = leafplot_obj(state.ptr, color = state.subplot_colors[*, state.mask_id], thick=2)
  endelse
  
  ;-update plot
  dendro_update_plot, state, subplot
  
end

pro dendro_update_mask, state, id

  ;- if new id = old id, don't do anything
  if id eq state.id[state.mask_id] then return
  if id lt 0 then return

  widget_control, /hourglass


  ;- compute delta between old and new
  ptr = state.ptr
  venn = dendrovenn(state.id[state.mask_id], id, (*ptr).clusters)

  ;- subtract a and not b
  if venn.anotb[0] ne -1 then begin
     for i = 0, n_elements(venn.anotb) - 1, 1 do begin
        ind = venn.anotb[i]
        dendro_delta_mask, state, ind, /subtract
     endfor
  endif

  ;- add b and not a
  if venn.bnota[0] ne -1 then begin
     for i = 0, n_elements(venn.bnota) - 1, 1 do begin
        ind = venn.bnota[i]
        dendro_delta_mask, state, ind, /add
     endfor
  endif
  
  ;- store id in state
  state.id[state.mask_id] = id
  
  ;- new dendro plot object
  subplot = (id ge 0) ? dplot_obj(state.ptr, id, color = state.subplot_colors[*,state.mask_id], thick=2) : $
            obj_new()
  
  dendro_update_plot, state, subplot
end

pro dendro_delta_mask, state, id, add = add, subtract = subtract
  ptr = state.ptr
  doAdd = keyword_set(add) || ~keyword_set(subtract)
  if id lt 0 || id ge n_elements((*ptr).cluster_label_h) then return
  if (*ptr).cluster_label_h[id] eq 0 then return

  if doAdd then begin
     ind = (*ptr).cluster_label_ri[(*ptr).cluster_label_ri[id] : $
                                      (*ptr).cluster_label_ri[id+1]-1]
     (*state.mask)[(*ptr).x[ind], (*ptr).y[ind], (*ptr).v[ind]] or= ishft(1, state.mask_id)
  endif else begin
     ind = (*ptr).cluster_label_ri[(*ptr).cluster_label_ri[id] : $
                                   (*ptr).cluster_label_ri[id+1]-1]
     (*state.mask)[(*ptr).x[ind], (*ptr).y[ind], (*ptr).v[ind]] and= not ishft(1, state.mask_id)
  endelse
end

pro dendro_update_plot, state, subplot
  id = state.id

  ;- update dendrogram plots
  if obj_valid(state.subplot[state.mask_id]) then begin
     state.model->remove, state.subplot[state.mask_id]
  endif
  obj_destroy, state.subplot[state.mask_id]
  if obj_valid(subplot) then begin
     state.subplot[state.mask_id] = subplot
     state.model->add, state.subplot[state.mask_id], pos=0
  endif
  
  state.draw->request_redraw
  state.z->update_images
end

pro dendrogui_cleanup, id
  widget_control, id, get_uvalue = info
  obj_destroy, [info.dendro, info.model, $
               info.draw, $
               info.z, info.subplot]
  ptr_free, info.mask
end

pro dendrogui, ptr

  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, 'dendrogui, ptr'
     return
  endif

  ;- make a cube
  cube = fltarr(max((*ptr).x)+1, max((*ptr).y)+1, max((*ptr).v)+1)
  cube[(*ptr).x, (*ptr).y, (*ptr).v] = (*ptr).t
  nanswap, cube, 0
  cubeptr = ptr_new(cube)

  ;- Dendrogram plot object of the entire hierarchy
  dendro = dplot_obj(ptr, max((*ptr).clusters+1))
  model = obj_new('IDLgrModel')
  model->add, dendro

  ;- guis
  tlb = widget_base(/column, /tlb_size_events)
  desc = replicate({flags:0, name:''}, 9)
  desc[[0,8]].flags=[1,2]
  desc.name=['Mask', 'Red', 'Blue', 'Orange', $
             'Purple', 'Yellow', 'Teal', 'Brown', 'Green']
  toprow = widget_base(tlb, /row)
  menu = cw_pdmenu(toprow, desc)
  label = widget_label(toprow, value='              ')
  bottomrow=widget_base(tlb)
  xra = minmax((*ptr).xlocation) + range((*ptr).xlocation)*[-.05,.05]
  yra = minmax((*ptr).height) + range((*ptr).height)*[-.05,.05]
  draw = obj_new('pzwin', model, bottomrow, $
                 xrange = xra, $
                 yrange = yra, $
                 /keyboard)
  model->add, obj_new('idlgraxis', direction=1, range=yra)
  
  ;- slice views
  z = obj_new('slice3', cubeptr, slice = 2, group_leader = tlb, xoffset = 1000, yoffset=500, $
             widget_listen=tlb)


  color = transpose(fsc_color(['crimson', 'royalblue', 'orange', 'purple', $
                               'yellow', 'teal', 'brown', 'green'], /triple))
  mask = ptr_new(byte(cube*0))
  mim3 = obj_new('cnbgrmask', mask, alpha=.8, blend=[3,4], slice=2, $
                 /noscale, nmask = 8, color = color)

  z->add_image, mim3
  
  ;- state information
  state = {$
          ptr:ptr, $               ;-dendrogram pointer
          mask:mask, $             ;-pointer to masked cube
          
          tlb:tlb, $               ;-top level base holding dendro plot
          toprow:toprow, $         ;-base widget id holding the menubar
          bottomrow:bottomrow, $   ;-base widget id holding the dendro plot

          draw:draw, $             ;-pzwin for dendrogram plot
          dendro:dendro, $         ;-main dendrogram plot object
          subplot:objarr(8), $     ;-dendrogram substructure plot objects 
          model:model, $           ;-idlgrmodel holding dendrogram plots
          z:z, $                   ;-slice3 window for cube
          label:label, $           ;-widget label on dendro plot

          subplot_colors:color, $  ;-colors for each mask -- [3,8] byte array
          id:replicate(-1, 8), $   ;-dendro id for each mask
          
          listen:1B, $             ;-updating masks?
          drag:0B, $               ;-mouse drags?
          old_listen:1B, $         ;-listen state before dragging
          leaf_id: -1, $           ;-which mask traces leaves
          mask_id: 0, $            ;-currently-edited mask
          menu:menu}
  
  z->run
  widget_control, tlb, /realize, set_uvalue = state

  xmanager, 'dendrogui', cleanup='dendrogui_cleanup', tlb, /no_block
end
  
  

  
