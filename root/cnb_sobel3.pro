;+
; PURPOSE:
;  This procedure computes the 3D sobel operator, to approximate the
;  spatial derivatives of a data cube
;
; INPUTS:
;  image: A 3D data cube
;
; OUTPUTS:
;  x: The x gradient
;  y: The y gradient
;  z: The z gradient
;
; METHOD:
;  The Sobel operator approximates the derivative based on the values
;  of pixels within a 3x3x3 box
;
; MODIFICATION HISTORY:
;  June 2010: Written by Chris Beaumont
;-
pro cnb_sobel3, image, x, y, z

  ;- parameter checking
  if n_params() ne 4 then begin
     print, 'calling sequence:'
     print, ' cnb_sobel3, image, x, y, z'
     return
  end
  nd = size(image, /n_dim)
  sz = size(image)
  if nd ne 3 || min(sz[1:3] lt 3) then $
     message, 'image must be a 3D cube, with at least 3 pixels along each dimension'
  
  ;- calculation
  z = image * 0
  x = image * 0
  y = image * 0
  mask = [2,1]
  for dx = -1, 1, 1 do begin
     for dy = -1, 1, 1 do begin
        for dz = -1, 1, 1 do begin
           sh = shift(image, dx, dy, dz)
           xc = mask[abs(dy)] * mask[abs(dz)] * (-dx)
           yc = mask[abs(dz)] * mask[abs(dy)] * (-dy)
           zc = mask[abs(dx)] * mask[abs(dy)] * (-dz)
           x += xc * sh
           y += yc * sh
           z += zc * sh           
        endfor
     endfor
  endfor
  return
end


pro test

  im = dist(25)
  cnb_sobel, im, mag, theta
  im = rebin(im, 25, 25, 25)
  cnb_sobel3, im, x, y, z
end
