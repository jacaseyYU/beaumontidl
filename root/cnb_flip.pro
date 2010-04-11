;+
; PURPOSE:
;  This function mirror flips an image horizontally and/or
;  vertically. 
;
; INPUTS:
;  image: A 2d image to flip
;
; KEYWORD PARAMETERS:
;  x: Set to flip along the horizontal direction
;  y: Set to flip along the vertical direction
;  both: Set to flip both horizontally and vertically
;
; RETURNS:
;  A flipped version of image
;
; RESTRICTIONS:
;  You must choose exactly one of /x, /y, or /both.
;
; MODIFICATON HISTORY:
;  March 2010: Written by Chris Beaumont
;-
function cnb_flip, image, x = x, y = y, both = both
  compile_opt idl2
  on_error, 2

  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, 'result = cnb_flip(image, [/x, /y, /both]'
     return, !values.f_nan
  endif

  ndimen = size(image, /n_dimen)
  if ndimen ne 2 then $
     message, 'image must be a 2d array'

  sz = size(image)

  x = indgen(sz[1])
  y = indgen(sz[2])
  
  x = rebin(x, sz[1], sz[2])
  y = rebin(1#y, sz[1], sz[2])
  
  if keyword_set(x) then begin
     x = sz[1] - 1 - x
     return, image[x,y]
  endif

  if keyword_set(y) then begin
     y = sz[2] - 1 - y
     return, image[x,y]
  endif

  if keyword_set(both) then begin
     y = sz[2] - 1 - y
     x = sz[1] - 1 - x
     return, image[x,y]
  endif

  message, 'must choose /x, /y, /both'
  return, 0
end

