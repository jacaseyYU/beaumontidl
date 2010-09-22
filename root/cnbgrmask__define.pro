pro cnbgrmask::restretch
  case self.slice of
     0: subim = (*self.raw_data)[self.pos[0], *, *]
     1: subim = (*self.raw_data)[*, self.pos[1], *]
     2: subim = (*self.raw_data)[*, *, self.pos[2]]
  endcase
  subim = byte(reform(subim))
  sz = size(subim)

  ;- convert into 3-color via lookup
  ;- this will fail in cnbgrimage::init, so 
  ;- check for a null lookup poiter first

  if ~ptr_valid(self.lookup) then return
  result= bytarr(4, sz[1], sz[2])
  result[0,*,*] = (*self.lookup)[0, subim]
  result[1,*,*] = (*self.lookup)[1, subim]
  result[2,*,*] = (*self.lookup)[2, subim]
  result[3,*,*] = 255 * (max(result, dim=1) ne 0) * self.alphachannel

  self->setproperty, data = result
end

function cnbgrmask::init, mask, $
                     colors = colors, $
                     nmask = nmask, $
                     pos = pos, slice = slice, $
                     black = black, white=white, $
                     _extra = extra
  if n_elements(mask) eq 0 then begin
     print, 'Calling sequence:'
     print, "obj = obj_new('CNBgrMask', data, [options])"
     return, 0
  endif

  junk = self->CNBgrImage::init(mask, pos = pos, slice = slice, $
                                black = black, white = white, $
                                /noscale, $
                                _extra = extra)

  csz = size(colors)
  MAX_MASK = 8
  if n_elements(colors) ne 0 then begin
     cdim = size(colors, /n_dim)
     if cdim ne 2 && csz[1] ne 3 then $
        message, 'colors must be a [3, ncolor] array'
     ncolor = csz[2]
     if csz[2] gt MAX_MASK then $
        message, 'Cannot have more than 8 colors'
     self.colors = ptr_new(colors)
  endif else begin
     ncolor = keyword_set(nmask) ? nmask : 3
     if ncolor gt 8 then message, 'Cannot have more than 8 colors'
     loadct, 25, /silent
     tvlct, vec, /get
     vec = transpose(vec)
     colors = vec[*, findgen(ncolor) / ((ncolor -1) > 1) * 255.]
     self.colors = ptr_new(colors)
  endelse

  ;- create lookup table
  lookup = bytarr(3, 255)
  for i = 0, 255 - 1, 1 do begin
     first = 1
     for j = 0, ncolor - 1, 1 do begin
        if ~(ishft(i, -j) and 1) then continue
        if first then begin
           first = 0
           lookup[*,i] = colors[*,j]
        endif else begin
           lookup[*,i] = .5 * lookup[*,i] + .5 * colors[*,j]
        endelse
     endfor
  endfor
  self.lookup = ptr_new(lookup)
  self->restretch
  return, 1
end
  
                                
pro cnbgrmask__define
  data = {CNBgrMask, inherits CNBgrImage, $
          colors: ptr_new(), $
          lookup: ptr_new()}
end


pro test
  cube = randomn(seed, 64, 64, 64)
  
  mask = cube gt 1
  mask += 2 * (randomn(seed, 64, 64, 64) gt 1)
  print, minmax(mask)
  mptr = ptr_new(mask)
  im = obj_new('CNBgrMask', mptr, nmask=5, alpha=.8, blend=[3,4])
  im2 = obj_new('CNBgrImage', cube);, alpha=.5, blend=[3,4])

  win = obj_new('idlgrwindow')
  model = obj_new('idlgrmodel')
  view = obj_new('idlgrview', viewplane=[0,0,64,64])

  model->add, im2
  model->add, im

  view->add, model
  win->draw, view

  obj_destroy,view
end
