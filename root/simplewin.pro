pro simplewin_event, event
  widget_control, event.id, get_uval = id
  widget_control, event.top, get_uval = info

  case id of 
     'draw': begin
        st = string(event.x, event.y, format='(i3, 3x, i3)')
        print, st
        widget_control, info.coords, $
                        set_value = st
        if event.release eq 1 then $
           visualize, info.region, event.x, event.y, info.width, $
                      info.plane
     end
     'width': begin
        widget_control, event.id, get_value = wid
        info.width = wid
        info.width = e
     end
     'plane:' begin
        info.plane = event.value
        redraw, info
     end
     else:
  endcase
  widget_control, event.top, set_uvalue = info
end

pro redraw, info
  ;xxx common
  widget_control, info.win, get_value = val
  wset, val
  tvimage, bytscl(sigrange(n[*,*,info.plane]))
end

pro simplewin, region
  
  sz = size(image)

  tlb = widget_base(row = 1)
  left = widget_base(tlb)
  right = widget_base(tlb, column = 1)

  win = widget_draw(left, xsize = sz[1], ysize = sz[2], $
                    uvalue = 'draw', /motion)
  row1 = widget_base(right, row = 1)
  junk = widget_label(row1, value = 'Plane: ')
  plane = widget_slider(row1, min = 0, max = sz[3]-1, uvalue='plane')
  
  row2 = widget_base(right, row = 1)
  junk = widget_label(row2, value = 'Width:')
  width = widget_text(row2, value = '8', /edit, uvalue = 'width')
  
  row3 = widget_base(right, row = 1)
  junk = widget_label(row3, value='(X, Y)')
  coords = widget_label(row3, value='')
  
  widget_control, tlb, /realize
  info = {coords: coords, plane: plane, win:win, width:8, $
         region: region, plane: 100}
  widget_control, tlb, set_uvalue = info

  widget_control, win, get_value = val
  wset, val
  tvimage, bytscl(image)
  xmanager, 'simplewin', tlb
end
