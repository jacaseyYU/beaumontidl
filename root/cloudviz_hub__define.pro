pro cloudviz_hub::receiveEvent, event, _extra = extra
  if obj_valid(self.listener) then $
     self.listener->event, event
end

function cloudviz_hub::getListener
  return, self.listener
end

pro cloudviz_hub::addListener, listener
  if ~obj_valid(listener) || ~obj_isa(listener, 'cloudviz_listener') then $
     message, 'listener is not a valid cloud_listener object'
  self.listener = listener
end

pro cloudviz_hub::addClient, client
  self->add, client
end

pro cloudviz_hub::add, client
  if ~obj_valid(client) || ~obj_isa(client, 'cloudviz_client') then $
     message, 'hubs can only hold cloudviz_client objects'
  self->IDL_CONTAINER::add, client
  client->run
end

pro cloudviz_hub::setCurrentStructure, structure, force = force

  ;- store new structure
  if ptr_valid(self.structure_ids[self.currentID]) then begin
     old = *(self.structure_ids[self.currentID])
     if array_equal(structure, old) then return
     *(self.structure_ids[self.currentID]) = structure
  endif else $
     self.structure_ids[self.currentID] = ptr_new(structure)

  ;- broadcast update to clients
  clients = self->IDL_CONTAINER::get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyStructure, self.currentID, structure, force = force
  endfor

end

pro cloudviz_hub::cleanup
  ptr_free, [self.pixelLabels, self.clusters, self.structure_ids]
end

function cloudviz_hub::getColors, index
  return, self.colors[*,index]
end

pro cloudviz_hub::setColor, index, color
  self.colors[*,index] = byte(color * [1,1,1,256] < 255)
  clients = self->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyColor, index, color
  endfor
end

pro cloudviz_hub::setCurrentID, id
  self.currentID = id
  clients = self->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyCurrent, id
  endfor
end

function cloudviz_hub::getCurrentID
  return, self.currentID
end

function cloudviz_hub::getStructure, index
  return, ptr_valid(self.structure_ids[index]) ? *self.structure_ids[index] : -1
end

function cloudviz_hub::getCurrentStructure
  return, self->getStructure(self.currentID)
end

function cloudviz_hub::getData
  return, self.data
end

function cloudviz_hub::init, ptr, colors = colors

  if size(ptr, /type) ne 10 || ~ptr_valid(ptr) || $
     size(*ptr, /type) ne 8 || ~contains_tag(*ptr, 'CLUSTERS') || $
     ~contains_tag(*ptr, 'CLUSTER_LABEL_H') || $
     ~contains_tag(*ptr, 'CLUSTER_LABEL_RI')|| $
     ~contains_tag(*ptr, 'CLUSTER_LABEL') || $
     ~contains_tag(*ptr, 'VALUE') then $
        message, 'Pointer does not point to a structure with the proper tags'
     
     
  self.data = ptr

  if keyword_set(colors) then begin
     sz = size(colors)
     if sz[0] ne 2 || sz[1] ne 4 || sz[2] ne 8 then $
        message, 'Colors keyword must be a [4,8] byte array'
     self.colors = colors
  endif else begin
     colors = byte(transpose(fsc_color( $
              ['red', 'teal', 'orange', 'purple', 'yellow', $
               'brown', 'royalblue', 'green'], /triple)))
     assert, n_elements(colors[0,*]) eq 8
     self.colors[0:2,*] = colors
     self.colors[3,*] = 255B
  endelse

  self.isListening = 1

  return, 1
end

pro cloudviz_hub__define
  data = {cloudviz_hub, $
          inherits IDL_CONTAINER, $
          listener:obj_new(), $
          gui: obj_new(), $
          data: ptr_new(), $
          colors: bytarr(4, 8), $
          structure_ids: ptrarr(8), $
          currentID: 0, $
          isListening: 0B $
         }
end
