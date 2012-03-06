pro dendroviz_listener::event, event
  kbrd_ev = contains_tag(event, 'TYPE') && $
     contains_tag(event, 'RELEASE') && $
     (event.type eq 5 || event.type eq 6) && event.release

  if kbrd_ev then self->keyboardEvent, event

end

pro dendroviz_listener::selectSubstructures
  ptr = self.hub->getData()
  ids = self.hub->getCurrentStructure()
  if min(ids) lt 0 then return
  hit = byte((*ptr).height * 0)
  for i = 0, n_elements(ids) - 1, 1 do begin
     hit[leafward_mergers(ids[i], (*ptr).clusters)] = 1
  endfor
  result = where(hit, ct)
  if ct eq 0 then return
  self.hub->setCurrentStructure, result
end

pro dendroviz_listener::selectByID
  desc = [ $
         '0, LABEL, Pick an ID, CENTER', $
         '1, BASE,, ROW, FRAME', $
         '0, INTEGER, 0, LABEL_LEFT=ID:, WIDTH=6, TAG=id', $
         '1, BASE,, ROW', $
         '0, BUTTON, OK, QUIT,' $
         + 'TAG=OK', $
         '2, BUTTON, Cancel, QUIT, TAG=CANCEL']
  choice = cw_form(desc, /column)
  if choice.cancel eq 1 then return
  id = choice.id
  ptr = self.hub->getData()
  if id lt 0 or id ge n_elements((*ptr).height) then return
  self.hub->setCurrentStructure, id
end

pro dendroviz_listener::keyboardEvent, event
  ptr = self.hub->getData()

  ;- ascii-key press
  if event.type eq 5 then begin
     case strupcase(event.ch) of
        '0': self.hub->setCurrentID, 0
        '1': self.hub->setCurrentID, 1
        '2': self.hub->setCurrentID, 2
        '3': self.hub->setCurrentID, 3
        '4': self.hub->setCurrentID, 4
        '5': self.hub->setCurrentID, 5
        '6': self.hub->setCurrentID, 6
        '7': self.hub->setCurrentID, 7
        'X': self.hub->setCurrentStructure, -2
        'L': self.hub->setCurrentStructure, get_leaves((*ptr).clusters)
        'F': self.hub->forceUpdate
        'S': self->selectSubstructures
        'I': self->selectByID
        else:
     endcase
     return
  endif

  ;- non-ascii
  ;- handle left, right, down keys
  if event.type eq 6 then begin
     LEFT = 5 & RIGHT = 6 & DOWN = 8
     id = self.hub->getCurrentStructure()
     parents = leafward_mergers(max(id), (*ptr).clusters, /parent)
     partner = merger_partner(max(id), (*ptr).clusters, merge = child)

     if (event.key eq LEFT || event.key eq RIGHT) then begin
        if parents[0] eq -1 then return
        l = parents[0] & r = parents[1]
        if (*ptr).xlocation[l] gt (*ptr).xlocation[r] then swap, l, r
        sub_id = (event.key eq LEFT) ? l : r
        sub_id = leafward_mergers(sub_id, (*ptr).clusters)
        self.hub->setCurrentStructure, sub_id

     endif else if event.key eq DOWN then begin
        if partner[0] eq -1 then return
        self.hub->setCurrentStructure, leafward_mergers(child, (*ptr).clusters)

     endif
  endif

end

pro dendroviz_listener__define
  data = {dendroviz_listener, $
          inherits cloudviz_listener}
end
