function cloudslice::event, event
  super = self->slice3::event(event)
  if size(super, /tname) ne 'STRUCT' then return, 0
  ptr = self.hub->getData()
  
  self.hub->receiveEvent, super

  if ~self.listener_toggle->check_listen(super) then return, 0
  if ~contains_tag(super, 'TYPE') || super.type ne 2 then return, 0
  if ~contains_tag(super, 'X') || ~contains_tag(super, 'Y') || $
     ~contains_tag(super, 'Z') then return, 0

  struct = ((*ptr).cluster_label)[super.X, super.Y, super.Z]
  self.hub->setCurrentStructure, struct
  return, 0
end

pro cloudslice::notifyStructure, index, structure
  ptr = self.hub->getData()
  val = ishft(1, index)

  ;- clear out index, re-calculate
  (*self.mask)[*] and= (not val)
  for i = 0, n_elements(structure) - 1, 1 do begin
     s = structure[i]
     if (*ptr).cluster_label_h[s] then continue
     ind = (*ptr).cluster_label_ri[ (*ptr).cluster_label_ri[s] : $
                                    (*ptr).cluster_label_ri[s+1]-1]
     (*self.mask)[ind] or= val
  endfor

  ;- update plots -- probably extra commands in here
  c = self.hub->getColors(index)
  self.maskobj->set_color, index, c[0:2]
  self.maskobj->redraw
  self->update_images
  self->request_redraw
end  

pro cloudslice::cleanup
  self->cloudviz_client::cleanup
  self->slice3::cleanup
  obj_destroy, self.maskobj
  ptr_free, self.mask
end


function cloudslice::init, hub
  if ~self->cloudviz_client::init(hub) then return, 0
  ptr = hub->getData()

  cube = (*ptr).value
  mask = byte(cube * 0)

  sz = size(cube)
  if sz[0] ne 3 then $
     message, 'data in cloudslice hub must describe a cube'

  self.mask = ptr_new(mask, /no_copy)
  self.maskobj = obj_new('cnbgrmask', self.mask, nmask = 8, $
                         slice = 2, /noscale, alpha = 1, blend=[3,4])
  if ~self->slice3::init(ptr_new(cube, /no_copy), slice = 2) then return, 0
  return, 1
end


pro cloudslice__define
  data = {cloudslice, $
          inherits cloudviz_client, $
          inherits slice3, $
          mask:ptr_new(), $
          maskobj:obj_new() $
         }
end
