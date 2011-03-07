pro bwclip_select__event, event
  widget_control, event.top, get_uvalue = ptr
  help, event, /struct

  case event.id of
     (*ptr).draw: begin
        print, 'draw event'
     end
     (*ptr).low: begin
        print, 'low event'
     end

     (*ptr).hi: begin
        print, 'hi event'
     end
     
     (*ptr).apply: begin
        widget_control, event.top, /destroy
     end

     (*ptr).cancel: begin
        (*ptr).doCancel = 1
        widget_control, event.top, /destroy
     end

     else:
  endcase
  
  ;- get lo, hi values
  widget_control, (*ptr).low, get_value = lo
  widget_control, (*ptr).hi, get_value = lo
end

function bwclip_select, im, cancel = cancel

  tlb = widget_base(/col)
  draw = widget_draw(tlb, xsize = 400, ysize = 200, /mouse_event)
  tbase = widget_base(tlb, /row)
  low = cw_field(tbase, title='Low')
  hi = cw_field(tbase, title='Hi')

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
  h = histogram(v, nbin = (gct / 10) < 1e3, loc = l)

  widget_control, tlb, /realize

  ;- plot
  widget_control, self.draw, get_value = wid
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
  xmanager, 'bwclip', tlb

  return, [(*ptr).lval, (*ptr).hval]

end

pro test
  im = dist(256)
  print, bwclip_select(im)
end
