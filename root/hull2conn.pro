;+
; PURPOSE:
;  This converts the convex hull output from qhull (2D) into a 1D
;  connectivity list for use in IDLgrPolygons
;
; INPUTS:
;  tr: The output to qhull. A [2,n] matrix when making hulls in 2D,
;  and a [3,n] matrix when making hulls in 3D. hull2con will convert
;  hulls of any dimension, though IDLgrPolygons will only work when
;  the hull lives in 2- or 3-D.
;
; OUTPUTS:
;  The connectivity list corresponding to tr
;
; MODIFICATION HISTORY:
;  October 2010: Written by Chris Beaumont
;-
function hull2conn, tr
  if n_params() ne 1 then begin
     print, 'result = hull2conn(tr)'
     return, !values.f_nan
  endif
  
  sz = size(tr)
  if sz[0] ne 2 then $
     messsage, 'input must be a 2D array'

  out = ulonarr(n_elements(tr) + sz[2])
  
  ind = ulindgen(sz[2]) * (sz[1] + 1)
  out[ind] = sz[1]
  for i = 0, sz[1] - 1, 1 do out[ind+i+1] = tr[i,*]
  return, out
end
