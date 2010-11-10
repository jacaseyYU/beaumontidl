;+
; PURPOSE:
;  This function computes the genus number for an (assumed) manifold
;  triangular mesh. The genus number is equal to the number of
;  "handles" in the surface.
;
; INPUTS:
;  Vert: A [3,n] array of vertices
;  Conn: The connectivity array of the mesh
;
; OUTPUTS:
;  The Genus number, or NAN if the program detects an invalid mesh
;
; RESTRICTIONS:
;  The formula used to calculate the genus number is only valid when
;  the mesh is traingular and manifold. The program doesn't do
;  much checking to ensure this is the case. Caveat emptor.
;
; MODIFICATION HISTORY:
;  November 2010: Written by Chris Beaumont
;-
function genus, vert, conn
;  if ~mesh_issolid(conn) then return, !values.f_nan
  ntri = mesh_numtriangles(conn)
  nvert = (size(vert))[2]
  return, (ntri - 2 * nvert + 4.)/4.
end

pro test
  
  sz = 35
  im = fltarr(sz, sz, sz)
  indices, im, x, y, z
  x-=sz/2 & y -= sz/2 & z -= sz/2
  r = sqrt(x^2 + y^2 + z^2)
  r2 = sqrt((x+5)^2 + (y)^2 + z^2)
  
  mask = (r lt 10)
  donut = mask and (sqrt(x^2 + y^2)  gt 4)

;  isosurface, donut, .9999, v, c
  isosurface, r, 10, v, c

  x = mesh_validate(v, c)
  print, mesh_issolid(c)
  print, mesh_numtriangles(c)
  print, mesh_volume(v, c)
  print, genus(v, c)
  
  xobjview, obj_new('idlgrpolygon', v, poly=c, color = [255,0,0])
end
  
