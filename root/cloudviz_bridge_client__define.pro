pro cloudviz_bridge_client::setListen, listen
  self.doListen = listen
end

pro cloudviz_bridge_client::notifyStructure, id, structure, force = force
  if ~sef.doListen then return
  self.bridge->notifyStructure, id, structure, self.hub, force = force
end
  

function cloudviz_bridge_client::init, hub, bridge
  if ~self->cloudviz_client::init(hub) return, 0
  self.doListen = 1B
  self.bridge = bridge
  return, 1
end

pro cloudviz_bridge_client::cleanup
  obj_destroy, self.bridge
end

pro cloudviz_bridge_client__define
  data = {cloudviz_bridge_client, $
          inherits cloudviz_client, $
          bridge: obj_new(), $
          doListen:0B}
end
