;+
; CLASS_NAME:
;  CNBgrImage
;
; PURPOSE:
;  This is a graphics class intended to hold 2- or 3-D data, for
;  eventual 2D display
;
; CATEGORY:
;  Graphics
;
; SUPERCLASSES:
;  IDLgrImage
;
; SUBCLASSES:
;  CNBgrMask
;
; DESCRIPTION:
;  The class manages a 3D cube (a 2D image is treated as a 3D cube
;  with a depth of 1 along the third dimension). A slice attribute
;  defines over what dimension (and at what location) to extract 2D
;  sub-images. 
;
;  The data can be of any type, and need not be scaled to
;  0-255. Appropriate instance variables and class methods specify the
;  transfer from data values to byte-scaled values
;
; METHODS:
;  SET_SLICE        Set the slice dimension
;  GET_2D_SLICE     return the slice index
;  GET_SLICE_SIZE   return the length of the cube along the slice
;                   dimension
;  SET_SLICE_INDEX  Set the index along the slice dimension at which
;                   the 2D image is extracted
;  GET_POS          Return the 3D location in the cube
;  SET_POS          Set the 3D location in the cube
;  SET_STRETCH      Set greyscale parameters
;  CONVERT_COORDS   Permute screen position (x,y,slice) to 3D cube position
;  REDRAW        Re-generate the 2D image
;  INIT             Create a new image object
;  CLEANUP          Destroy the image and free heap variables
;  
; MODIFICATION HISTORY:
;  September 2010: Written by Chris Beaumont
;-

pro CNBgrImage::set_slice, slice
  if slice ne 0 && slice ne 1 && slice ne 2 then slice = 2
  self.slice = slice
end

function CNBgrImage::get_2d_size
  case self.slice of 
     0: return, self.sz[1:2]
     1: return, self.sz[[0,2]]
     2: return, self.sz[0:1]
     else:
  endcase
  ;-cant get here
end

function CNBgrImage::get_slice_size
  return, self.sz[self.slice]
end

pro CNBgrImage::set_slice_index, index
  if self.pos[self.slice] eq index then return
  self.pos[self.slice] = 0 > index < (self.sz[self.slice] - 1)
  self->redraw
end

function CNBgrImage::get_slice
  return, self.slice
end

function CNBgrImage::get_pos
  return, self.pos
end

pro CNBgrImage::set_pos, x = x, y = y, z = z
  if n_elements(x) ne 0 then self.pos[0] = 0 > x < (sz[0] - 1)
  if n_elements(y) ne 0 then self.pos[1] = 0 > y < (sz[1] - 1)
  if n_elements(z) ne 0 then self.pos[2] = 0 > z < (sz[2] - 1)
  self->redraw
end

pro CNBgrImage::set_stretch, bias = bias, contrast = contrast, black = black, white = white, $
                             sqrt = sqrt, log = log, linear = linear

  if keyword_set(black) then self.black = black
  if keyword_set(white) then self.white = white
  if keyword_set(bias) then self.bias = bias
  if keyword_set(contrast) then self.contrast = contrast
  if keyword_set(sqrt) then self.scale='SQRT'
  if keyword_set(log) then self.scale='LOG'
  if keyword_set(linear) then self.scale='LINEAR'
  self->redraw
end

function CNBgrImage::convert_coords, x, y, z, valid = valid
  valid = 1
  case self.slice of
     0: result = [z, x, y]
     1: result = [x, z, y]
     2: result = [x, y, z]
     else: 
  endcase

  if min(result) lt 0 || $
     result[0] ge self.sz[0] || $
     result[1] ge self.sz[1] || $
     result[2] ge self.sz[2] then valid = 0

  return, result
end

pro CNBgrImage::redraw
  compile_opt idl2, hidden

  case self.slice of
     0: subim = (*self.raw_data)[self.pos[0], *, *]
     1: subim = (*self.raw_data)[*, self.pos[1], *]
     2: subim = (*self.raw_data)[*, *, self.pos[2]]
  endcase
  if self.noscale then begin
     subim = byte(subim)
  endif else begin
     ;-ds9-like scaling
     ;- map data values onto the range [0,1]
     case self.scale of
        'LINEAR': begin
           subim = 0 > ((subim - self.black) / (self.white - self.black)) < 1
        end
        ;- XXX need to handle negative values
        'SQRT': begin
           subim = 0 > ((sqrt(subim) - sqrt(self.black>0)) / (sqrt(self.white) - sqrt(self.black>0))) < 1
        end
        'LOG': begin
           hit = where(subim gt 0, ct)
           min = ct eq 0 ? 1d-5 :  min(subim[hit])
           subim = 0 > ((alog(subim) - alog(self.black > min)) / (alog(self.white) - alog(self.black > min))) < 1
        end
        else: message, 'unexpected scaling method'
     endcase

     ;- map onto black-white ramp
     ;- picture a graph: xaxis is (scaled) data. yaxis is greyscale
     ;- function is a line which passes through bias at y=0, at
     ;- an angle = pi/2 - contrast * pi
     ;- limits of y are [-1, 1]
     theta = !pi/2 - self.contrast * !pi
     subim = -1 > ((subim - self.bias) * tan(theta)) < 1

     ;- finally, map -1,1 to 0,255
     subim = byte((subim + 1) * 127.5)

  endelse
  sz = size(reform(subim))
  
  ;- convert to 3 color
  result = bytarr(4, sz[1], sz[2])
  result[0,*,*] = self.sh_color[0] * subim
  result[1,*,*] = self.sh_color[1] * subim
  result[2,*,*] = self.sh_color[2] * subim
  result[3,*,*] = self.alphachannel * subim
  self->setproperty, data = result
end

function CNBgrImage::init, data, $
                           pos = pos, slice = slice, $
                           black = black, white = white, $
                           color = color, noscale=noscale, $
                           _extra = extra

  junk = self->IDLgrImage::init(_extra = extra)

  if n_elements(data) eq 0 then begin
     print, 'calling sequence:'
     print, "obj = obj_new('CNBgrImage', data, [options])"
     return, 0
  endif

  isPtr = size(data, /type) eq 10
  if isPtr then begin
     dataPtr = data
     dataVal = *data
  endif else begin
     dataPtr = ptr_new(data)
     dataVal = data
  endelse
  sz = size(dataVal)
  ndim = size(dataVal, /n_dim)
  if ndim eq 2 then sz[3] = 1

  if n_elements(pos) eq 0 then pos = sz[1:3]/2 else begin
     if n_elements(pos) eq 2 then pos = [pos, 0]
     if n_elements(pos) ne 3 then $
        message, 'pos must be a 2 or 3 element vector'
     pos[0] = 0 > pos[0] < (sz[1] - 1)
     pos[1] = 0 > pos[1] < (sz[2] - 1)
     pos[2] = 0 > pos[2] < (sz[3] - 1)
  endelse

  default_slice = ndim eq 2 ? 2 : 0
  if n_elements(slice) eq 0 then slice = default_slice else begin
     if slice ne 0 && slice ne 1 && slice ne 2 then $
        message, 'slice must be 0, 1, or 2'
  endelse

  big = n_elements(dataVal) gt 1e6
  if big then begin
     hit = where(dataVal ne 0, ct)
     rand = randomu(seed, 1e5) * ct
     sub = dataVal[hit[rand]]
     med = median(sub) & sig = medabsdev(sub, /sigma)
  endif else begin
     hit = where(dataVal ne 0, ct)
     if ct ne 0 then begin
        med = median(dataVal[hit]) & sig = medabsdev(dataVal[hit], /sigma)
     endif else begin
        med = median(dataVal) & sig = medabsdev(dataVal, /sigma)
     endelse
  endelse
  
  if n_elements(black) eq 0 then black = med - 5 * sig
  if n_elements(white) eq 0 then white = med + 5 * sig
  if ~keyword_set(color) then color = [1., 1., 1.]

  self.minmax = minmax(dataVal, /nan)
  self.black = black
  self.white = white
  self.bias = 0.5
  self.contrast = .25
  self.scale='LINEAR'
  self.raw_data = dataPtr
  self.sz = sz[1:3]
  self.pos = pos
  self.slice = slice
  self.sh_color = color
  self.noscale = keyword_set(noscale)
  self->redraw
 
  return, 1
end

pro CNBgrImage::cleanup
  self->IDLgrImage::cleanup
  ptr_free, self.raw_data
  assert, ~ptr_valid(self.data)
  ptr_free, self.data
end

pro CNBgrImage__define
  data = {CNBgrImage, inherits IDLgrImage, $
          raw_data:ptr_new(), $  ;- pointer to the data cube
          sz:intarr(3), $        ;- size of the data cube
          pos: fltarr(3), $      ;- position in the cube
          slice:0, $             ;- dimension of slicing
          noscale:0B, $          ;- Ignore greyscale parameters?
          scale: '', $           ;- name of scaling function. LINEAR, LOG, or SQRT
          black:0., $            ;- data value of black
          white:0., $            ;- data value of white
          bias:0., $             ;- greyscale bias (normalized value of middle grey)
          contrast:0., $         ;- contrast (ramp from black to white). 0-1
          sh_color:fltarr(3), $  ;- tint of the image (RGB triplet)
          minmax: fltarr(2) $    ;- min and max data value
         }
end


pro test

  cube = randomn(seed, 128, 128, 128)

  im = obj_new('CNBgrImage', cube)
;  im->setProperty, data = bytscl(dist(128))
  win = obj_new('idlgrwindow')
  model = obj_new('idlgrmodel')
  view = obj_new('idlgrview', viewplane = [0, 0, 128, 128])

  model->add, im
  view->add, model
  win->draw, view

  wait, .1
  cube = rebin(dist(128), 128, 128, 128)
  im2 = obj_new('CNBgrImage', cube, slice = 2, color=[1.,0.,0.], alpha=.3, $
                blend=[3,4])
  model->add, im2, pos = 1
  win->draw, view

  obj_destroy, view
end
  
