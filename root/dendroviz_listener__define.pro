pro dendroviz_listener::event, event
  kbrd_ev = contains_tag(event, 'TYPE') && $
     contains_tag(event, 'RELEASE') && $
     (event.type eq 5 || event.type eq 6) && event.release

  if kbrd_ev then self->keyboardEvent, event
  
end

pro dendroviz_listener::keyboardEvent, event
  ptr = self.hub->getData()

  ;- ascii-key press
  if event.type eq 5 then begin
     case strupcase(event.ch) of
        '1': self.hub->setCurrentID, 0
        '2': self.hub->setCurrentID, 1
        '3': self.hub->setCurrentID, 2
        '4': self.hub->setCurrentID, 3
        '5': self.hub->setCurrentID, 4
        '6': self.hub->setCurrentID, 5
        '7': self.hub->setCurrentID, 6
        '8': self.hub->setCurrentID, 7
        'X': self.hub->setCurrentStructure, -2 
        'L': self.hub->setCurrentStructure, get_leaves((*ptr).clusters) 
        'F': self.hub->forceUpdate
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
