pro dg_slice::set_substruct, index, substruct
  ptr = self.ptr

  venn = dendrovenn(self.substructs[index], substruct, (*ptr).clusters)

  self->dg_client::set_substruct, index, substruct, status
  if ~status then return

  
  for i = 0, venn.anotbct -1, 1 do begin
     ind = venn.anotb[i]
     self->delta_mask, index, ind, /subtract
  endfor
  for i = 0, venn.bnotact - 1, 1 do begin
     ind = venn.bnota[i]
     self->delta_mask, index, ind, /add
  endfor
  self.substructs[index] = substruct
  self->update_images
  self->request_redraw
end

pro dg_slice::delta_mask, value, id, subtract = subtract, add = add
  ptr = self.ptr
  doAdd = keyword_set(add) || ~keyword_set(subtract)
  if id lt 0 || id ge n_elements((*ptr).cluster_label_h) then return
  if (*ptr).cluster_label_h[id] eq 0 then return
  
  ind = (*ptr).cluster_label_ri[(*ptr).cluster_label_ri[id] : $
                                (*ptr).cluster_label_ri[id+1]-1]
  if doAdd then begin
     (*self.mask)[(*ptr).x[ind], (*ptr).y[ind], (*ptr).v[ind]] or= ishft(1, value)
  endif else begin
     (*self.mask)[(*ptr).x[ind], (*ptr).y[ind], (*ptr).v[ind]] and= not ishft(1, value)
  endelse
end


function dg_slice::event, event
  super = self->slice3::event( event)

  if size(super, /tname) ne 'STRUCT' then return, 0
  ptr = self.ptr
  ;- find the substructure
  ind = where((*ptr).x eq floor(super.x) and $
              (*ptr).y eq floor(super.y) and $
              (*ptr).v eq floor(super.z), ct)
  id = ct eq 0 ? -2 : (*ptr).cluster_label[ind[0]]

  result = create_struct(super, 'substruct', id, $
                       name='DG_SLICE_EVENT')
  if self.listener ne 0 then $
     widget_control, self.listener, send_event = result
  return, result
end


pro dg_slice::cleanup
  self->slice3::cleanup
end

function dg_slice::init, ptr, color = color, listener = listener, _extra = extra
  ;- make a cube
  cube = fltarr(max((*ptr).x), max((*ptr).y), max((*ptr).v))
  cube[(*ptr).x, (*ptr).y, (*ptr).v] = (*ptr).t
  cube = ptr_new(cube, /no_copy)
  self.mask = ptr_new(byte(*cube * 0), /no_copy)

  junk = self->slice3::init(cube, slice = 2, _extra = extra)
  junk = self->dg_client::init(ptr, listener, color = color)

  self->add_image, obj_new('cnbgrmask', self.mask, nmask=8, slice=2, $
                           /noscale, color = color, alpha=1., blend=[3,4])
  return, 1
end

pro dg_slice__define
  data = {dg_slice, $
          inherits slice3, $
          inherits dg_client, $
          mask:ptr_new()}
end



pro test_event, event
  widget_control, event.top, get_uvalue = obj
  print, 'event'
  obj->set_substruct, 0, event.substruct
  print, event.substruct
end

pro test
  restore, '~/dendro/ex_ptr_small.sav'
  tlb = widget_base()
  widget_control, tlb, /realize
  dp = obj_new('dg_slice', ptr, listen = tlb)
  dp->run
  widget_control, tlb, set_uvalue = dp
  xmanager, 'test', tlb

  ptr_free, ptr
  help, /heap

end
