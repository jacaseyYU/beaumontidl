function cloudslice::event, event
  super = self->slice3::event(event)
  if size(super, /tname) ne 'STRUCT' then return, 0
  self.hub->receiveEvent, event
  ptr = self.hub->getData()
  
  self.hub->receiveEvent, super

  if ~self.listener_toggle->check_listen(super) then return, 0
  if ~contains_tag(super, 'TYPE') || super.type ne 2 then return, 0
  if ~contains_tag(super, 'X') || ~contains_tag(super, 'Y') || $
     ~contains_tag(super, 'Z') then return, 0

  sz = size((*ptr).cluster_label)
  if super.X lt 0 || super.x ge sz[1] || super.y lt 0 || super.y ge sz[2] || $
     super.Z lt 0 || super.z ge sz[3] then return, 0

  struct = ((*ptr).cluster_label)[super.X, super.Y, super.Z]
  struct = leafward_mergers(struct, (*ptr).clusters)
  self.hub->setCurrentStructure, struct
  return, 0
end

pro cloudslice::notifyStructure, index, structure, force = force
  ptr = self.hub->getData()
  val = ishft(1, index)

  ;- clear out index, re-calculate
  (*self.mask)[*] and= (not val)
  for i = 0, n_elements(structure) - 1, 1 do begin
     s = structure[i]
     if s lt 0 || s ge n_elements((*ptr).cluster_label_h) then continue

     if (*ptr).cluster_label_h[s] eq 0 then continue
     ind = (*ptr).cluster_label_ri[ (*ptr).cluster_label_ri[s] : $
                                    (*ptr).cluster_label_ri[s+1]-1]
     (*self.mask)[ind] or= val
  endfor

  ;- update plots
  self.maskobj->redraw
;  self->update_images
  self->request_redraw
end  

pro cloudslice::notifyCurrent, id
  self.listener_toggle->set_listen, 0
end

pro cloudslice::notifyColor, index, color
  self.maskobj->set_color, index, color[0:2]
  self.maskobj->redraw
  self->request_redraw
end

pro cloudslice::run
  self->slice3::run
end

pro cloudslice::cleanup
  self->cloudviz_client::cleanup
  self->slice3::cleanup
  obj_destroy, [self.maskobj, self.listener_toggle]
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
  colors = bytarr(3, 8)
  for i = 0, 7, 1 do colors[*,i] = (hub->getColors(i))[0:2]

  self.maskobj = obj_new('cnbgrmask', self.mask, nmask = 8, $
                         color = colors, $
                         slice = 2, /noscale, alpha = 1, blend=[3,4])
  if ~self->slice3::init(ptr_new(cube, /no_copy), slice = 2) then return, 0
  self->add_image, self.maskobj
  self.listener_toggle = obj_new('listener_toggle')
  self.widget_base = self.base
  return, 1
end


pro cloudslice__define
  data = {cloudslice, $
          inherits cloudviz_client, $
          inherits slice3, $
          mask:ptr_new(), $
          listener_toggle:obj_new(), $
          maskobj:obj_new() $
         }
end
