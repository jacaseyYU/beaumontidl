pro cloudviz_client::sendEventToHub, event, _extra = extra
  self.hub->receiveEvent, event, _extra = extra
end

pro cloudviz_client::notifyCurrent, id
  ;- do nothing by default
end

pro cloudviz_client::notifyColor, id, color
  ;- do nothign by default
end

pro cloudviz_client::notifyStructure, id, structure, force = force
  ;- do nothing by default
end

pro cloudviz_client::run
  ;- do nothing by default
end

pro cloudviz_client::cleanup
  if self.hub->getLeader() eq self then obj_destroy, self.hub
  if widget_info(self.widget_base, /valid) then $
     widget_control, self.widget_base, /destroy
end

function cloudviz_client::getWidgetBase
  return, self.widget_base
end

function cloudviz_client::init, hub
  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, 'obj = obj_new("cloudviz_client", hub)'
     return, 0
  endif

  if n_elements(hub) ne 1 || ~obj_isa(hub, 'cloudviz_hub') $
     then message, 'hub is not a valid cloudviz hub object'

  self.hub = hub
  return, 1
end

pro cloudviz_client__define
  data = {cloudviz_client, $
          hub:obj_new(), $
          widget_base:0L $
         }
end
