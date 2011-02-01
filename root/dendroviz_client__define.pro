pro dendroviz_client::cleanup
  self->cloudviz_client::cleanup
end

function dendroviz_client::init, hub
  if ~(self->cloudviz_client::init(hub)) then return, 0
  ptr = hub->getData()
  if ~contains_tag(*ptr, 'height') || $
     ~contains_tag(*ptr, 'xlocation') then $
        message, 'hub is missing height and/or xloc data'
  return, 1
end

pro dendroviz_client__define
  data = {dendroviz_client, $
          inherits cloudviz_client}
end
