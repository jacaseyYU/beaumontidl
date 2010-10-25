;+
; PURPOSE:
;  This function re-orders the description of a 3D polygon returned,
;  e.g., by functions like ISOSURFACE. The order is such that, when
;  the object is transformed by a transformation matrix, the individual
;  polyogon faces are arranged from back to front. This is helpful when
;  rendering transparent polygons with IDL Object graphics. Because of the way
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
; t:  The 4x4 transformation matrix. See IDL documentation
;     "Coordinates of 3D Graphics"
;
; OUTPUTS:
;  A re-arranged version of c, such that the triangle faces are
;  arranged from back to front when rotated by rot.
;
; RESTRICTIONS:
;  Only triangular polygonal faces are allowed.
;
; MODIFICATION HISTORY:
;  December 2009: Written by Chris Beaumont
;  October 2010: Added support for an arbitrary transformation matrix.
;-
function orderpolys, v, c, t
  compile_opt idl2
  
  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, ' new_c = orderpolys(vert, conn, t)'
     return, !values.f_nan
  endif

  sz = size(t) & nd = size(t, /n_dim)
  if nd ne 2 || sz[1] ne 4 || sz[2] ne 4 then $
     message, 't must be a 4x4 transformation matrix'
  sz = size(v) & nd = size(v, /n_dim)
  if nd ne 2 || sz[1] ne 3 then $
     message, 'v must be a [3,n] vertex matrix'

  x = v[0,*]
  y = v[1,*]
  z = v[2,*]
 
  ;- transform coordinates
  xp = x * t[0] + y * t[1] + z * t[2] + t[3]
  yp = x * t[4] + y * t[5] + z * t[6] + t[7]
  zp = x * t[8] + y * t[9] + z * t[10] + t[11]
  w = x * t[12] + y * t[13] + z * t[14] + t[15]
  xp /= w & yp /= w & zp /= w
    
  n = n_elements(c)  
  if n mod 4 ne 0 then $
     message, 'connectivity vector c must consist of triangular faces only'
  n /= 4

  ind = lindgen(n) * 4

  if range(c[ind]) ne 0 || c[ind[0]] ne 3 then $
     message, 'connectivity vector c must consist of triangular faces only'

  ;- the mean transformed z coordinate of each face 
  order = (zp[c[ind + 1]] + zp[c[ind + 2]] + zp[c[ind + 3]]) / 3.
    
  s = sort(order) * 4
  result = transpose([[c[s]], [c[s+1]], $
                      [c[s+2]], [c[s+3]]])
  result = reform(result, n * 4, /over)
  
  ;- final sanity check
  ;assert, range(result[ind]) eq 0 and result[ind[0]] eq 3

  return, result
end
  
  
  
