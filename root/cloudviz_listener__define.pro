pro cloudviz_listener::event, event
  message, 'not implemented'
end

function cloudviz_listener::init, hub
  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, ' obj = obj_new("cloudviz_listener", hub)'
     return, 0
  endif

  if ~obj_valid(hub) || ~obj_isa(hub, 'cloudviz_hub') then $
     message, 'hub is not a valid cloudviz_hub object'

  self.hub = hub
  return, 2
end


pro cloudviz_listener__define
  data = {cloudviz_listener, $
          hub:hub() $
         }
end
