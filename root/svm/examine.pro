pro update_loc, event
  if ~event.press then return 
  widget_control, event.top, get_uvalue = ptr
  widget_control, event.id, get_uvalue = id
  i = event.x
  j = event.y
  case id of 
     'xy': begin
        x = i & y = j & z = (*ptr).z
     end
     'yz': begin
        x = (*ptr).x & y = i & z = j
     end
     'xz': begin
        x = i & y = (*ptr).y & z = j
     end
  endcase
  (*ptr).x = x & (*ptr).y = y & (*ptr).z = z
  widget_control, (*ptr).x_slider, set_value = x
  widget_control, (*ptr).y_slider, set_value = y
  widget_control, (*ptr).z_slider, set_value = z
  
  draw, (*ptr).xy, 'XY', ptr, /docontour
  draw, (*ptr).yz, 'YZ', ptr, /docontour
  draw, (*ptr).xz, 'XZ', ptr, /docontour
end
  
;- draw to a given window
pro draw, wid, slice, ptr, docontour = docontour
  wset, wid
  x = (*ptr).x & y = (*ptr).y & z = (*ptr).z
  case strupcase(slice) of
     'XY' : begin
        mask = (*ptr).mask[*, *, z]
        seed_x = x
        seed_y = y
        im = (*ptr).im_scale[*, *, z]
     end
     'YZ' : begin
        mask = (*ptr).mask[x, *, *]
        im = (*ptr).im_scale[x, *, *]
        seed_x = y
        seed_y = z
     end
     'XZ' : begin
        mask = (*ptr).mask[*, y, *]
        im = (*ptr).im_scale[*, y, *]
        seed_x = x
        seed_y = z
     end
  endcase
  mask = reform(mask)
  pos = [0, 0, 1, 1]
  tvimage, im, pos = pos, /keep
  tvcircle, 3, seed_x, seed_y, color = fsc_color('green')
  if ~keyword_set(docontour) then return
  ;- -1 contour in red
;  contour, mask eq -1, xsty = 5, ysty = 5, pos = pos, color = fsc_color('red'), /noerase
  ;- 1 contour in green
  contour, mask eq 1, xsty = 5, ysty = 5, pos = pos, /noerase, color = $
           fsc_color('green')
end

pro save_mask, ptr, open = open
  file = dialog_pickfile(read = keyword_set(open), write = ~keyword_set(open), $
                         overwrite_prompt = ~keyword_set(open), $
                        default_extension = 'sav')
  if strlen(file) eq 0 then return
  if keyword_set(open) then begin
     restore, file
     (*ptr).mask = fix(mask)
     print, minmax(mask)
     return
  endif
  mask = (*ptr).mask
  save, mask, file = file
end

pro train_event, event
  widget_control, event.top, get_uvalue = ptr
  widget_control, event.id, get_uvalue = id
  widget_control, event.id, get_value = val
  ;print, val, (*ptr).z
  case strupcase(id) of
     'PLANE' : (*ptr).plane = event.index
     'X' : (*ptr).x = val
     'Y' : (*ptr).y = val
     'Z' : (*ptr).z = val
     'SEED' : (*ptr).seed = event.index
     'LOW' : (*ptr).lo = val
     'HIGH' : (*ptr).hi = val
     'OPEN' : (*ptr).open = val
     else :  ;- do nothing
  endcase
  ;- should we re-calculate the mask?
  switch strupcase(id) of
     'PLANE':
     'SEED':
     'LOW':
     'HIGH':
     'OPEN': calculate_mask, ptr
  endswitch
  if strupcase(id) eq 'CLEAR' then (*ptr).mask *= 0
  
  ;- update the displays?
  id = strupcase(id)
  docontour = (id ne 'X' && id ne 'Y' && id ne 'Z' ) || event.drag eq 0
  draw, (*ptr).xy, 'XY', ptr, docontour = docontour
  draw, (*ptr).yz, 'YZ', ptr, docontour = docontour
  draw, (*ptr).xz, 'XZ', ptr, docontour = docontour

  ;- update the masks?
  if id eq 'UPDATE_AND' || id eq 'UPDATE_OR' || id eq 'UPDATE_ANDNOT' then $
     combine_masks, ptr, id

  ;- save the masks?
  if id eq 'SAVE' then save_mask, ptr

  ;- open a new mask?
  if id eq 'OPEN_FILE' then save_mask, ptr, /open
end

pro examine
  ;- read the image, trim the edges
  im = mrdfits('mosaic.fits',0,h,/silent)
  sz = size(im)
  mask = reform(finite(im[*,*,0]))
  mask = erode(mask, replicate(1B, 25, 25))
  mask = rebin(mask, sz[1], sz[2], sz[3])
  bad = where(mask eq 0 or ~finite(im))
  im[bad] = !values.f_nan

  sz = size(im)
  mean = total(im,3,/nan) / sz[3]
  peak = max(im,dim=3,/nan)

  im[bad] = 0

  nanswap, peak, 0
  nanswap, mean, 0


  ;- make the widgets
  tlb = widget_base(column = 1)
  xz = widget_base(column = 1, group_leader = tlb, title = 'XZ', xoffset = 500, $
                  xsize = sz[1], ysize = sz[3])
  xy = widget_base(column = 1, group_leader = tlb, title = 'XY', $
                   xoffset = 500 + 2 * sz[1], xsize = sz[1], ysize = sz[2])
  yz = widget_base(column = 1, group_leader = tlb, title = 'YZ', xoffset = 500 + sz[1], $
                  xsize = sz[2], ysize = sz[3])

  xzd = widget_draw(xz, xsize = sz[1], ysize = sz[3], $
                    uvalue = 'xz', event_pro = 'update_loc', /button_e)
  xyd = widget_draw(xy, xsize = sz[1], ysize = sz[2], $
                    uvalue = 'xy', event_pro = 'update_loc', /button_e)
  yzd = widget_draw(yz, xsize = sz[2], ysize = sz[3], $
                    uvalue = 'yz', event_pro = 'update_loc', /button_e)


  sec1 = widget_base(tlb, column = 2)
  sec1_l = widget_base(sec1, column = 1)
  sec1_r = widget_base(sec1, row = 1)


  ;-channel selectors
  wid_slide = 250
  sec2 = widget_base(tlb, column = 1)
  
  row1 = widget_base(sec2, row = 1)
  junk = widget_label(row1, value='x', xsize = wid)
  x_slider = widget_slider(row1, min = 0, max = sz[1]-1, uvalue = 'x', $
                       value = sz[1]/2, /drag, xsize = wid_slide)
 
  row2 = widget_base(sec2, row = 1)
  junk = widget_label(row2, value='y', xsize = wid)
  y_slider = widget_slider(row2, min = 0, max = sz[2]-1, uvalue = 'y', $
                       xsize = wid_slide, value = 141, /drag)
  
  row3 = widget_base(sec2, row = 1)  
  junk = widget_label(row3, value='z', xsize = wid)
  z_slider = widget_slider(row3, min = 0, max = sz[3]-1, uvalue = 'z', $
                       xsize = wid_slide, value = 299, /drag)

  ;- update, save options
  sec3 = widget_base(tlb, column = 1)
  row = widget_base(sec3, row = 1)
  open = widget_button(row, value = 'Open...', uvalue = 'open_file')

  ;- set up the info structure
  widget_control, tlb, /realize
  widget_control, xy, /realize
  widget_control, xz, /realize
  widget_control, yz, /realize

  widget_control, xyd, get_value = xyv
  widget_control, yzd, get_value = yzv
  widget_control, xzd, get_value = xzv
  ;print, xyd, xy
  ;print, yzd, yz
  ;print, xzd, xz
  restore, 'emission_class.sav'
  info = {im : im, mean : bytscl(mean), $
          x : sz[1] / 2, y : 141, z : sz[3] / 2, $
          mask : mask, im_scale : bytscl(im), $
          xy : xyv, yz : yzv, xz : xzv, $
          x_slider : x_slider, y_slider : y_slider, z_slider : z_slider}
  infoptr = ptr_new(info, /no_copy)
  
  widget_control, tlb, set_uvalue = infoptr
  widget_control, xy, set_uvalue = infoptr
  widget_control, xz, set_uvalue = infoptr
  widget_control, yz, set_uvalue = infoptr

  draw, xzv, 'XZ', infoptr, /docontour
  draw, xyv, 'XY', infoptr, /docontour
  draw, yzv, 'YZ', infoptr, /docontour

  xmanager, 'train', tlb, /no_block
  xmanager, 'train', xz, /no_block
  xmanager, 'train', yz, /no_block
  xmanager, 'train', xy, /no_block

;  ptr_free, infoptr
end
