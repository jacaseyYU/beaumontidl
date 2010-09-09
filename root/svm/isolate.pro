pro isolate_event, event
  widget_control, event.top, get_uvalue = infoptr
  widget_control, event.id, get_uvalue = id
  widget_control, event.id, get_value = val
;  stop
;  print, id
  case id of
     'hv': (*infoptr).hival = double(val)
     'lv': (*infoptr).loval = double(val)
     'ov': (*infoptr).openval = fix(val)
     'ch': (*infoptr).channel = val
     'src': (*infoptr).src =  event.index
     'mod': (*infoptr).mode = event.index
     else:
  endcase
  if id eq 'upd' then isolate_update_mask, infoptr
  if id ne 'ch' && id ne 'sav' then isolate_update, infoptr

  isolate_channel, infoptr, contour = id ne 'ch' || event.drag eq 0


  if id eq 'sav' then isolate_save, infoptr
end

pro isolate_update_mask, s
  print, 'in update'
  mode = (*s).mode
  final_mask = (*s).final_mask
  mask = (*s).mask
  if mode eq 0 then (*s).final_mask = mask
  if mode eq 1 then (*s).final_mask = mask or final_mask
  if mode eq 2 then (*s).final_mask = ~mask and final_mask
  if mode eq 3 then (*s).final_mask = mask and final_mask
end

pro isolate_save, s
  outfile = dialog_pickfile(/write, /overwrite_prompt)
  mask = (*s).final_mask
  save, mask, file = outfile
end

pro isolate_channel, s, contour = contour

  plane = (*s).im[*,*,(*s).channel]
  pos = [0,0,.5,.5]
  tvimage, nanscale(sigrange(plane)), pos = pos, /keep
  if keyword_set(contour) then begin
     contour, (*s).mask, ysty=5, xsty=5, pos = pos, /noerase, $
              color = fsc_color('red')
     contour, (*s).final_mask, pos = pos, /noerase, color = fsc_color('blue'), $
              xsty=5, ysty=5
  endif
end

pro isolate_update, s
  ;- calculate mask
  case (*s).src of 
     0: compare = (*s).mean
     1: compare = (*s).peak
     2: compare = (*s).im[*,*,(*s).channel]
  endcase

  maskhi = (compare gt (*s).hival)
  masklo = (compare gt (*s).loval)
  if max(maskhi) eq 0 then return
  mask = masklo * 0B
  r = label_region(masklo, /ulong)
  h = histogram(r, min = 1, rev = ri)
  for i = 0L, n_elements(h) - 1, 1 do begin
     if h[i] eq 0 then continue
     if max(maskhi[ri[ri[i] : ri[i+1]-1]]) eq 1 then $
        mask[ri[ri[i] : ri[i+1]-1]] = 1B
  endfor
  if (*s).openval gt 0 then $
     mask = morph_open(mask, replicate(1B, (*s).openval, (*s).openval))
  (*s).mask = mask
  ;- show results
  sz = size((*s).mean)
  window, 0, xsize = 600 > (2 * sz[1]) < 900, $
          ysize = 600 > (2 * sz[2]) < 900
  pos = [0, .5, .5, 1]
  tvimage, nanscale(sigrange((*s).mean)), pos=pos, /keep

  contour, mask, pos = pos, /noerase, color = fsc_color('red'), $
           xsty=5, ysty=5
  contour, (*s).final_mask, pos = pos, /noerase, color = fsc_color('blue'), $
           xsty=5, ysty=5

  tvimage, nanscale(mask), pos=[.5,.5,1,1], /keep
  pos = [.5, 0, 1, .5]
  tvimage, nanscale(sigrange((*s).peak)), pos = pos,/keep
  contour, mask, pos = pos, /noerase, color = fsc_color('red'), $
           xsty=5, ysty=5
  contour, (*s).final_mask, pos = pos, /noerase, color = fsc_color('blue'), $
           xsty=5, ysty=5
 
  xyouts, .25, .95, 'Mean Image', /norm
  xyouts, .75, .95, 'Mask', /norm
  xyouts, .25, .45, 'Masked Image', /norm
  xyouts, .75, .45, 'Peak Image', /norm
end


pro isolate

  im = mrdfits('mosaic.fits',0,h,/silent)
  sz = size(im)
  ;- trim 15 pixels off edge
  mask = reform(finite(im[*,*,0]))
  mask = erode(mask, replicate(1B, 25, 25))
  mask = rebin(mask, sz[1], sz[2], sz[3])
  bad = where(mask eq 0 or ~finite(im))
  im[bad] = !values.f_nan

  sz = size(im)
  mean = total(im,3,/nan) / sz[3]
  peak = max(im,dim=3,/nan)

  im[bad] = 0

  bad = where(~finite(peak), badct)
  if badct ne 0 then peak[bad] = 0

  tlb = widget_base(column = 1)
  
  row1 = widget_base(tlb, row=1)
  lab1 = widget_label(row1, value='Hi Thresh')
  hival = widget_text(row1, uvalue = 'hv', /edit, value = '1')
  
  row2 = widget_base(tlb, row=1)
  lab2 = widget_label(row2, value = 'Lo Thresh')
  loval = widget_text(row2, uvalue = 'lv', /edit, value='.5')

  row3 = widget_base(tlb, row=1)
  lab3= widget_label(row3, value='Open Size')
  openval = widget_text(row3, uvalue='ov', /edit, value='0')

  channel = widget_slider(tlb, min = 0, max = n_elements(im[0,0,*])-1, $
                          uvalue = 'ch', value = 40, /drag)

  row4 = widget_base(tlb, row=1)
  masksrc = widget_droplist(row4, value=['Mask from Mean', 'Mask from Peak', $
                                        'Mask from Plane'], uvalue='src')
  mode = widget_droplist(row4, value=['New', 'Add', 'Subtract', 'Union'], uval='mod')
  update = widget_button(tlb, value='Update Mask', uvalue='upd')
  save = widget_button(tlb, value='save', uvalue='sav')
  
  info = {im:im, mean:mean, peak:peak, $
          hival:1., loval:.5, openval:0, channel : 0, $
          mask:byte(peak*0), final_mask:byte(peak*0), $
          src:0, mode:0}
  infoptr = ptr_new(info, /no_copy)
  widget_control, tlb, set_uvalue = infoptr
  widget_control, tlb, /realize
  
  xmanager, 'isolate', tlb
  ptr_free, infoptr

end
