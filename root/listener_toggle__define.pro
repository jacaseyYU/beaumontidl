function listener_toggle::check_listen, event
  if ~contains_tag(event, 'LEFT_CLICK') || $
     ~contains_tag(event, 'RIGHT_CLICK') || $
     ~contains_tag(event, 'LEFT_DRAG') || $
     ~contains_tag(event, 'RIGHT_DRAG') || $
     ~contains_tag(event, 'RIGHT_RELEASE') || $
     ~contains_tag(event, 'LEFT_RELEASE') $
  then return, self.listen


  if event.LEFT_CLICK || event.RIGHT_CLICK then begin
     self.old_listen = self.listen
     self.listen = 0
  endif
  
  if event.LEFT_DRAG then self.drag = 1
  if event.LEFT_RELEASE then begin
     if (self.drag) then self.listen = self.old_listen $
     else self.listen = ~self.old_listen
     self.drag = 0
  endif
  if event.RIGHT_RELEASE then begin
     self.listen = self.old_listen
     self.drag = 0
  endif
  return, self.listen
end
     

pro listener_toggle::set_listen, val
  self.listen = 0
end

pro listener_toggle__define
  data = {listener_toggle, $
          listen:0B, $
          old_listen:0B, $
          drag:0B $
         }
end
