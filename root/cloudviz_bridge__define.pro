pro cloudviz_bridge::notifyStructure, id, structure, hub, force = force
  print, keyword_set(force)
  self.client1->setListen, 0
  self.client2->setListen, 0
  match = (*self.match)
  if hub eq self.hub1 then begin
     d = self.hub2->getData()
     ;- selection in PPV, echo in PPP
     c = self.hub2->getCurrentID()
     if min(structure) lt 0 then s = -1 else begin
        ;- match root of selected hierarchy
        s = match[max(structure)]
        ;- select all substructures
        s = leafward_mergers(s,(*d).clusters)
     endelse
     self.hub2->setCurrentID, id
     self.hub2->setCurrentStructure, s, force = force
     self.hub2->setCurrentID, c
     if keyword_set(force) then self.hub2->forceUpdate
  endif else begin
     ;- echo from PPP to PPV
     hit = bytarr( n_elements(match))
     for i = 0, n_elements(structure) - 1 do hit or= (match eq structure[i])
     c = self.hub1->getCurrentID()
     s = where(hit)
     self.hub1->setCurrentID, id
     self.hub1->setCurrentStructure, s, force = force
     self.hub1->setCurrentID, c
  endelse

  self.client1->setListen, 1
  self.client2->setListen, 1
end

pro cloudviz_bridge::notifyColor, id, color, hub
end

function cloudviz_bridge::init, hub1, hub2, match
  if size(hub1, /type) ne 11 || $
     size(hub2, /type) ne 11 || $
     ~obj_isa(hub1, 'cloudviz_hub') || $
     ~obj_isa(hub2, 'cloudviz_hub') then $
        message, 'hubs must be cloudviz_hub objects'
  self.hub1 = hub1
  self.hub2 = hub2
  self.client1 = obj_new('cloudviz_bridge_client', hub1, self)
  self.client2 = obj_new('cloudviz_bridge_client', hub2, self)
  self.match = ptr_new(match)

  hub1->addClient, self.client1
  hub2->addClient, self.client2
  return, 1

end

pro cloudviz_bridge::cleanup
  obj_destroy, [self.hub1, self.hub2, self.client1, self.client2]
  ptr_free, self.match
end

pro cloudviz_bridge__define
  data = {cloudviz_bridge, $
          hub1: obj_new(), $
          hub2: obj_new(), $
          client1:obj_new(), $
          client2:obj_new(), $
          match: ptr_new() }
end
