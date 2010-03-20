;+
; PURPOSE:
;  This function returns the (x,y,z) position along a line
;  which is closest to a reference point. 
;
;  The routine is vectorized so that multiple lines can be fed into
;  the program at once. However, only one (x,y,z) coordinate can be
;  specified. In this repsect, it is superior to the builtin
;  PNT_LINE. That routine, however, is generalized to n dimensions.
;
;  The algorithm is taken from
;  http://local.wasp.uwa.edu.au/~pbourke/geometry/pointline/
;
; CALLING SEQUENCE:
;  result = closestApproach(x, y, z, x0, y0, z0, x1, y1, z1 dist =
;  dist)
;
; INPUTS:
;  x: Single reference point X
;  y: Single reference point Y
;  z: Single reference point Z
;  x0: First of two x coordinates along a line
;  y0: First of two y coordinates along a line
;  z0: First of two z coordinates along a line
;  x1: Second of two x coordinates along a line
;  y1: Second of two y coordinates along a line
;  z1: Second of two z coordinates along a line
;
; OUTPUTS:
;  The point(s) (xf, yf, zf), along the line(s) described by (x0,y0,z0) and
;  (x1, y1, z1), that is closest to the point (x,y,z). This is a 3 row
;  by M column array.
;
; KEYWORD PARAMETERS:
;  dist: A variable which holds the distance(s) between (xf, yf, zf) and
;  (x, y, z)
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, Feb 2009
;-
function closestApproach, x, y, z, x0, y0, z0, x1, y1, z1, dist = dist

compile_opt idl2
;on_error, 2

;- check inputs
if n_params() ne 9 then begin
   print, 'closestApproach calling sequence:'
   print, 'result = closestApproach(x, y, z, '
   print, '                         x0, y0, z0, '
   print, '                         x1, y1, z1, '
   print, '                         [dist = dist])'
   print, ' (x,y,z) reference point'
   print, ' (x0, y0, z0) and (x1, y1, z1): points on line(s)'
   return, !values.f_nan
endif

if n_elements(x) ne 1 || n_elements(y) ne 1 || n_elements(z) ne 1 $
   then message, '(x,y,z) must each be scalars'

sz = n_elements(x0)
if n_elements(x1) ne sz || n_elements(y0) ne sz || $
   n_elements(y1) ne sz || n_elements(z0) ne sz || $
   n_elements(z1) ne sz then $
      message, '(x0, y0, z0) and (x1, y1, z1) must have the same number of elements'

if sz eq 0 then message, '(x0, y0, z0) and (x1, y1, z1) are undefined'

if (size(x0))[0] gt 1 || (size(x1))[0] gt 1 || $
   (size(y0))[0] gt 1 || (size(y1))[0] gt 1 || $
   (size(z0))[0] gt 1 || (size(z1))[0] gt 1 then $
      message, '(x0, y0, z0) and (x1, y1, z1) must be scalars or 1D arrays'

l2 = double( (x1 - x0)^2 + (y1 - y0)^2 + (z1 - z0)^2)
u =  ((x - x0) * (x1 - x0) + $
     (y - y0) * (y1 - y0) + $
     (z - z0) * (z1 - z0)) / l2

result = [[x0 + u * (x1 - x0)], $
         [y0 + u * (y1 - y0)], $
         [z0 + u * (z1 - z0)]]

dist = sqrt( (result[*, 0] - x)^2 + $
             (result[*, 1] - y)^2 + $
             (result[*, 2] - z)^2 )

;-put into the correcto format if only one point was calculated
if (size(x0))[0] eq 0 then begin
   result = reform(result, 1, 3)
   dist = [dist]
endif


return, result

end
