pro cloudviz_bridge::init, hub1, hub2, match
  if size(hub1, /type) ne 11 || $
     size(hub2, /type) ne 11 || $
     ~obj_isa(hub1, 'cloudviz_hub') || $
     ~obj_isa(hub2, 'cloudviz_hub') then $
        message, 'hubs must be cloudviz_hub objects'
  self.hub1 = hub1
  self.hub2 = hub2
  self.client1 = obj_new('cloudviz_bridge_client', hub1)
  self.client2 = obj_new('cloudviz_bridge_client', hub2)
  self.match = match

  hub1->addClient, self.client1
  hub2->addClient, self.client2
end

pro cloudviz_bridge::cleanup
  self->cloudviz_client::cleanup
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
