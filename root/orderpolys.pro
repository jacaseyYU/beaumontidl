;+
; PURPOSE:
;  This function re-orders the description of a 3D polygon returned,
;  e.g., by functions like ISOSURFACE. The order is such that, when
;  viewed from a certain rotation about the Y axis, the individual
;  polyogon faces are arranged from back to front. This is helpful when
;  transparent polygons with IDL Object graphics. Because of the way
;  IDL renders transparent objects, polygons located in the back of
;  the frame must be drawn first for the transparency to look correct.
;
; CATEGORY:
;  graphics
;
; INPUTS:
;  v: A [3,n] array of polygon vertices. Returned by processes like
;     ISOSURFACE
;  c: A vector describing how the vertices in V are arranged into
;     polygon faces. Note that, in this precedure, all polygon faces
;     must be triangles. This is the default behavior of
;     ISOSURFACE. This vector looks like [3,a,b,c,3,d,e,f,...]. The
;     first 3 indicates that the first polygon face has thee
;     vertices. The next 3 integers (a,b,c) give the row number, in v,
;     corresponding to each vertex in this polygon. The process
;     repeats for as many triangles as are in the surface.
; rot: The rotation of the surface about the y axis, in DEGREES
;      counter-clockwise. More complex rotations are currently not
;      supported. 
;
; OUTPUTS:
;  A re-arranged version of c, such that the triangle faces are
;  arranged from back to front when rotated by rot.
;
; RESTRICTIONS:
;  Only rotations about the y axis are implemented currently. Only
;  triangular polygonal faces are allowed.
;
; MODIFICATION HISTORY:
;  December 2009: Written by Chris Beaumont
;
;-
function orderpolys, v, c, rot
  compile_opt idl2
  
  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, ' new_c = orderpolys(vert, conn, rot)'
     return, !values.f_nan
  endif

  x = v[0,*]
  y = v[1,*]
  z = v[2,*]
 
  ;- compute the rotated z coordinate
  theta = rot * !dtor
  z2 = -x * sin(theta) + z * cos(theta)
    
  n = n_elements(c)
  
  if n mod 4 ne 0 then $
     message, 'connectivity vector c must consist of triangular faces only'
  n /= 4

  ind = lindgen(n) * 4

  if range(c[ind]) ne 0 || c[ind[0]] ne 3 then $
     message, 'connectivity vector c must consist of triangular faces only'

  ;- the mean rotated z coordinate of each face 
  order = (z2[c[ind + 1]] + z2[c[ind + 2]] + z2[c[ind + 3]]) / 3.
    
  s = sort(order) * 4
  result = transpose([[c[s]], [c[s+1]], $
                      [c[s+2]], [c[s+3]]])
  result = reform(result, n * 4)
  
  ;- final sanity check
  ;assert, range(result[ind]) eq 0 and result[ind[0]] eq 3

  return, result
end
  
  
  
