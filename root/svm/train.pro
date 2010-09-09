pro update_loc, event
  if ~event.press then return 
  widget_control, event.top, get_uvalue = ptr
  widget_control, event.id, get_uvalue = id
  i = event.x
  j = event.y

  
  case id of 
     'xy': begin
        x = i & y = j & z = (*ptr).z
        widget_control, (*ptr).planelist, set_droplist_select = 0
        (*ptr).plane = 0
     end
     'yz': begin
        x = (*ptr).x & y = i & z = j
        widget_control, (*ptr).planelist, set_droplist_select = 2
        (*ptr).plane = 2
     end
     'xz': begin
        x = i & y = (*ptr).y & z = j
        widget_control, (*ptr).planelist, set_droplist_select = 1
        (*ptr).plane = 1
     end
  endcase
  (*ptr).x = x & (*ptr).y = y & (*ptr).z = z
  widget_control, (*ptr).x_slider, set_value = x
  widget_control, (*ptr).y_slider, set_value = y
  widget_control, (*ptr).z_slider, set_value = z
  calculate_mask, ptr

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
        newmask = (*ptr).newmask[*, *, z]
        seed_x = x
        seed_y = y
        im = (*ptr).im_scale[*, *, z]
     end
     'YZ' : begin
        mask = (*ptr).mask[x, *, *]
        newmask = (*ptr).newmask[x, *, *]
        im = (*ptr).im_scale[x, *, *]
        seed_x = y
        seed_y = z
     end
     'XZ' : begin
        mask = (*ptr).mask[*, y, *]
        newmask = (*ptr).newmask[*, y, *]
        im = (*ptr).im_scale[*, y, *]
        seed_x = x
        seed_y = z
     end
  endcase
  mask = reform(mask) & newmask = reform(newmask)
  pos = [0, 0, 1, 1]
  tvimage, im, pos = pos, /keep
  tvcircle, 3, seed_x, seed_y, color = fsc_color('green')
  if ~keyword_set(docontour) then return
  contour, mask, xsty = 5, ysty = 5, pos = pos, color = fsc_color('red'), /noerase
  contour, newmask, xsty = 5, ysty = 5, pos = pos, /noerase, color = $
           fsc_color('skyblue')
end

;- generate a new mask
pro calculate_mask, ptr

     
  lo = (*ptr).lo
  hi = (*ptr).hi
  open = (*ptr).open
  x = (*ptr).x
  y = (*ptr).y
  z = (*ptr).z

  ;- box option is easy - to that first
  if (*ptr).dobox then begin
     (*ptr).newmask *= 0
     dx = (*ptr).dx
     dy = (*ptr).dy
     dz = (*ptr).dz
     sz = size((*ptr).newmask)
     (*ptr).newmask[(x-dx) > 0 : (x + dx) < (sz[1] - 1), $
            (y-dy) > 0 : (y + dy) < (sz[2] - 1), $
            (z-dz) > 0 : (z + dz) < (sz[3] - 1)] = 1
     return
  endif

  doseed = (*ptr).seed
  plane = (*ptr).plane
  
  case plane of 
     0 : begin
        data = reform((*ptr).im[*, *, z])
        sz = size(data)
        ind = x + y * sz[1]
     end
     1 : begin
        data = reform((*ptr).im[*, y, *])
        sz = size(data)
        ind = x + z * sz[1]
     end
     2 : begin
        data = reform((*ptr).im[x, *, *])
        sz = size(data)
        ind = y + z * sz[1]
     end
     3: begin
        calculate_mask_3d, ptr
        return
     end
  endcase
  if doseed then hi = data[ind]
  l1 = (data gt lo)
  l2 = (data gt hi)
  if max(l2) eq 0 then begin
     (*ptr).newmask = byte((*ptr).im * 0)
     return
  endif
  mask = l1 * 0B
  r = label_region(l1, /ulong)
  h = histogram(r, min = 1, rev = ri)
  for i = 0L, n_elements(h) - 1, 1 do begin
     if h[i] eq 0 then continue
     if max(l2[ri[ri[i] : ri[i+1]-1]]) eq 1 then $
        mask[ri[ri[i] : ri[i+1]-1]] = 1B
  endfor
  if doseed then begin
     r = label_region(mask, /ulong)
     mask *= 0
     if r[ind] ne 0 then mask[where(r eq r[ind])] = 1
  endif

  if open gt 0 then $
     mask = morph_open(mask, replicate(1B, open, open))
  ;- convert back to a cube
  sz = size((*ptr).im)
  (*ptr).newmask[*] = 0
  case plane of 
     0 : (*ptr).newmask[*, *, z] = mask
     1 : (*ptr).newmask[*, y, *] = mask
     2 : (*ptr).newmask[x, *, *] = mask
  endcase
end

pro calculate_mask_3d, ptr
  lo = (*ptr).lo
  hi = (*ptr).hi
  open = (*ptr).open
  x = (*ptr).x
  y = (*ptr).y
  z = (*ptr).z
  doseed = (*ptr).seed
  data = (*ptr).im

  if doseed then hi = data[x,y,z]
  l1 = (data gt lo)
  l2 = (data gt hi)
  if max(l2) eq 0 then begin
     (*ptr).newmask = byte((*ptr).im * 0)
     return
  endif
  mask = l1 * 0B
  r = label_region(l1, /ulong)
  h = histogram(r, min = 1, rev = ri)
  for i = 0L, n_elements(h) - 1, 1 do begin
     if h[i] eq 0 then continue
     if max(l2[ri[ri[i] : ri[i+1]-1]]) eq 1 then $
        mask[ri[ri[i] : ri[i+1]-1]] = 1B
  endfor
  if doseed then begin
     r = label_region(mask, /ulong)
     mask *= 0
     if r[x,y,z] ne 0 then mask[where(r eq r[x,y,z])] = 1
  endif

  ;- do morphological opening on each plane and each slice
  if (*ptr).open gt 0 then begin
     open = (*ptr).open
     sz = size(mask)
     elem = replicate(1B, open, open)
     for i = 0, sz[3] - 1, 1 do $
        mask[*,*,i] = morph_open(reform(mask[*,*,i]), elem)
     for i = 0, sz[1] - 1, 1 do $
        mask[i,*,*] = morph_open(reform(mask[i,*,*]), elem)
     for i = 0, sz[2] - 1, 1 do $
        mask[*,i,*] = morph_open(reform(mask[*,i,*]), elem)
  endif

  (*ptr).newmask = mask
end

  

pro combine_masks, ptr, method
  mask1 = (*ptr).mask
  mask2 = (*ptr).newmask
  case strupcase(method) of 
     'UPDATE_AND' : mask = mask1 and mask2
     'UPDATE_OR' : mask = mask1 or mask2
     'UPDATE_ANDNOT' : mask = mask1 and not mask2
  endcase
  (*ptr).mask = mask
end

pro save_mask, ptr, open = open
  file = dialog_pickfile(read = keyword_set(open), write = ~keyword_set(open), $
                         overwrite_prompt = ~keyword_set(open), $
                        default_extension = 'sav', filter='*.sav')
  if strlen(file) eq 0 then return
  if keyword_set(open) then begin
     restore, file
     (*ptr).mask = mask
     return
  endif
  mask = (*ptr).mask
  save, mask, file = file
end

pro train_event, event
  widget_control, event.top, get_uvalue = ptr
  widget_control, event.id, get_uvalue = id
  widget_control, event.id, get_value = val
  case strupcase(id) of
     'PLANE' : (*ptr).plane = event.index
     'X' : (*ptr).x = val
     'Y' : (*ptr).y = val
     'Z' : (*ptr).z = val
     'SEED' : (*ptr).seed = event.index
     'LOW' : (*ptr).lo = val
     'HIGH' : (*ptr).hi = val
     'OPEN' : (*ptr).open = val
     'DX' : (*ptr).dx = val
     'DY' : (*ptr).dy = val
     'DZ' : (*ptr).dz = val
     'BOX': (*ptr).dobox = event.index
     else :  ;- do nothing
  endcase
  ;- should we re-calculate the mask?
  switch strupcase(id) of
     'PLANE':
     'SEED':
     'LOW':
     'HIGH':
     'DX':
     'DY':
     'DZ':
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

pro train_cleanup, tlb
  widget_control, tlb, get_uvalue = ptr
  ptr_free, ptr
end

pro train
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


  ;-hi, lo, open threshholds
  wid = 60
  wid_txt = 7
  row1 = widget_base(sec1_l, row = 1)
  lab1 = widget_label(row1, xsize = wid, value='Hi Thresh')
  hival = widget_text(row1, uvalue = 'high', /edit, value = '1', xsize = wid_txt)

  row2 = widget_base(sec1_l, row = 1)
  lab2 = widget_label(row2, xsize = wid, value = 'Lo Thresh')
  loval = widget_text(row2, uvalue = 'low', /edit, value='.5', xsize = wid_txt)
  
  row3 = widget_base(sec1_l, row = 1)
  lab3 = widget_label(row3, xsize = wid, value = 'Open')
  openval = widget_text(row3, uvalue='open', /edit, value='0', xsize = wid_txt)

  ;- use a seed or not
  lab4 = widget_label(sec1_r, value='Use Seed?')
  seed = widget_droplist(sec1_r, value = ['No', 'Yes'], uvalue = 'seed')

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
                       xsize = wid_slide, value = sz[2]/2, /drag)
  
  row3 = widget_base(sec2, row = 1)  
  junk = widget_label(row3, value='z', xsize = wid)
  z_slider = widget_slider(row3, min = 0, max = sz[3]-1, uvalue = 'z', $
                       xsize = wid_slide, value = sz[3]/2, /drag)

  ;- update, save options
  sec3 = widget_base(tlb, column = 1)
  row1 = widget_base(sec3, row = 1)
  junk = widget_label(row1, value = 'Selection on:')
  planelist = widget_droplist(row1, value = ['XY', 'XZ', 'YZ', '3D'], uvalue= 'plane')
  
  junk = widget_label(sec3, value = 'Update:')
  row = widget_base(sec3, row = 1)
  b1 = widget_button(row, value = 'Intersect', uvalue='update_and')
  b2 = widget_button(row, value = 'Union', uvalue='update_or')
  b3 = widget_button(row, value = 'Subtract', uvalue='update_andnot')
  row = widget_base(sec3, row = 1)
  save = widget_button(row, value = 'Save...', uvalue = 'save')
  open = widget_button(row, value = 'Open...', uvalue = 'open_file')
  clear = widget_button(row, value = 'Reset', uvalue = 'clear')


  ;- 3D box selector widgets
  sec4 = widget_base(tlb, column = 1)
  lab = widget_droplist(sec4, value = ['No 3D box', '3D box'], uval = 'box')
  row1 = widget_base(sec4, row = 1)
  junk = widget_label(row1, value='x', xsize = wid)
  dx_slider = widget_slider(row1, min = 0, max = 20, uvalue = 'dx', $
                       value = 5, /drag, xsize = wid_slide)
 
  row2 = widget_base(sec4, row = 1)
  junk = widget_label(row2, value='y', xsize = wid)
  dy_slider = widget_slider(row2, min = 0, max = 20, uvalue = 'dy', $
                       xsize = wid_slide, value = 5, /drag)
  
  row3 = widget_base(sec4, row = 1)  
  junk = widget_label(row3, value='z', xsize = wid)
  dz_slider = widget_slider(row3, min = 0, max = 50, uvalue = 'dz', $
                       xsize = wid_slide, value = 15, /drag)



  ;- set up the info structure
  widget_control, tlb, /realize
  widget_control, xy, /realize
  widget_control, xz, /realize
  widget_control, yz, /realize

  widget_control, xyd, get_value = xyv
  widget_control, yzd, get_value = yzv
  widget_control, xzd, get_value = xzv
  info = {im : im, mean : bytscl(mean), $
          x : sz[1] / 2, y : sz[2] / 2, z : sz[3] / 2, $
          plane : 0, seed : 0, lo : 0.5, hi : 1., open : 0, $
          mask : byte(im * 0), $
          newmask : byte(im * 0), im_scale : bytscl(im), $
          xy : xyv, yz : yzv, xz : xzv, $
          x_slider : x_slider, y_slider : y_slider, z_slider : z_slider, $
          planelist : planelist, $
          dx : 5, dy : 5, dz : 15, dobox : 0};, $
;          dx_slider : dx_slider, dy_slider : dy_slider, dz_slider : dz_slider}
  infoptr = ptr_new(info, /no_copy)
  
  widget_control, tlb, set_uvalue = infoptr
  widget_control, xy, set_uvalue = infoptr
  widget_control, xz, set_uvalue = infoptr
  widget_control, yz, set_uvalue = infoptr

  draw, xzv, 'XZ', infoptr, /docontour
  draw, xyv, 'XY', infoptr, /docontour
  draw, yzv, 'YZ', infoptr, /docontour

  xmanager, 'train', tlb, cleanup = 'train_cleanup', /no_block
  xmanager, 'train', xz, /no_block
  xmanager, 'train', yz, /no_block
  xmanager, 'train', xy, /no_block

end
