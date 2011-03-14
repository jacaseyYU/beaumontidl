pro update_plot, ptr
  widget_control, (*ptr).draw, get_value = v
  wset, v

  plot, (*ptr).l, (*ptr).h, psym = 10, charsize = 1
  oplot, (*ptr).lval + [0,0], minmax((*ptr).h), color = fsc_color('red')
  oplot, (*ptr).hval + [0,0], minmax((*ptr).h), color = fsc_color('green')
end

pro bwclip_select_event, event
  widget_control, event.top, get_uvalue = ptr

  case event.id of
     (*ptr).draw: begin
        xyz = convert_coord(event.x, event.y, /device, /to_data)
        if event.press eq 1 then $
           (*ptr).lval = xyz[0]
        if event.press eq 4 then $
           (*ptr).hval = xyz[0]
     end
     (*ptr).low: begin
        widget_control, event.id, get_value = v
        v = float(v)
        (*ptr).lval = v
     end
     (*ptr).hi: begin
        widget_control, event.id, get_value = v
        v = float(v)
        (*ptr).hval = v
     end
     
     (*ptr).apply: begin
        widget_control, event.top, /destroy
        return
     end

     (*ptr).cancel: begin
        (*ptr).doCancel = 1
        widget_control, event.top, /destroy
        return
     end

     else:
  endcase
  update_plot, ptr

  ;- get lo, hi values
  widget_control, (*ptr).low, set_value = string((*ptr).lval, format='(e0.3)')
  widget_control, (*ptr).hi, set_value = string((*ptr).hval, format='(e0.3)')
end

function bwclip_select, im, cancel = cancel

  tlb = widget_base(/col)
  draw = widget_draw(tlb, xsize = 500, ysize = 300, /button)
  tbase = widget_base(tlb, /row)
  low = cw_field(tbase, title='Low', /return_events)
  hi = cw_field(tbase, title='Hi', /return_events)

  bbase = widget_base(tlb, /row)
  apply = widget_button(bbase, value='apply')
  cancel = widget_button(bbase, value='cancel')


  ;- histogram
  big = n_elements(im) gt 1d6
  good = where(finite(im), gct)
  if gct eq 0 then $
     message, 'No finite values'
  if big then begin
     r = randomu(seed, 1e5) * gct
     v = im[good[r]]
  endif else v = im[good]
  h = histogram(v, nbin = (gct / 10) < 1e2, loc = l)

  widget_control, tlb, /realize

  ;- plot
  widget_control, draw, get_value = wid
  wset, wid

  plot, l, h, psym = 10, charsize = 1.5
  oplot, l[0] + [0,0], minmax(h), color = fsc_color('red')
  oplot, max(l) + [0,0], minmax(h), color = fsc_color('green')

  widget_control, low, set_value = string(min(l), format='(e0.3)')
  widget_control, hi, set_value = string(max(l), format='(e0.3)')


  state = {low:low, hi:hi, apply:apply, cancel:cancel, h: h, l:l, draw:draw, doCancel:0B, $
           lval: min(l), hval: max(l)}

  ptr = ptr_new(state)
  widget_control, tlb, set_uvalue = ptr

  update_plot, ptr
  xmanager, 'bwclip_select', tlb

  cancel = 0
  if (*ptr).doCancel then begin
     cancel = 1
     result = [0,0]
  endif else result = [(*ptr).lval, (*ptr).hval]
  ptr_free, ptr
  return, result
end

pro test
  im = dist(256)
  print, bwclip_select(im)
end
