;+
; PURPOSE:
;  This function computes the integral of grad V over a closed
;  volume. This surface is calculated using ISOSURFACE
;
; INPUTS:
;  x: The x component of a vector field, sampled on a regular grid
;  y: The y component
;  z: The z component
;  verts: The vertice array, output from ISOSURFACE, defining a
;         closed triangular mesh
;  conn: The connectivity array output from ISOSURFACE.
;
; KEYWORD PARAMETERS:
;  unit: An optional keyword specifying the physical grid spacing. If
;  provided, then the output will be converted to physical
;  coordinates. Otherwise, the output will be given in terms of grid
;  coordinates (i.e. each point in the (x,y,z) grid is separated by 1
;  unit). 
;
; OUTPUTS:
;  The integral of grad V over the volume. The program uses the
;  divergence theorem, and sums V dot dA over the surface.
;
; RESTRICTIONS:
;  I'm a little worried about normal vectors, which don't quite seem
;  to be correctly oriented at the moment. Maybe this is just the
;  discreteness of the triangles
;
; MODIFICATION HISTORY:
;  June 2010: Written by Chris Beaumont
;-
function div3, x, y, z, verts, conn, unit = unit

  compile_opt idl2

  sz = n_elements(conn)
  nv = n_elements(verts[0,*])
  nf = sz / 4.

  assert, sz mod 4 eq 0 && $
     range(conn[indgen(nf)*4]) eq 0 && $
     conn[0] eq 3

  if ~keyword_set(unit) then unit = 1

  ;- compute outward-facing unit normals
  ;- this seems to be the average of the normals of 
  ;- the polygons that share this vertex
  ;- IDL Polys follow the right hand rule --
  ;- see NORMAL keyword in idlgrpolygon documentation.

  area = fltarr(nf) & norms = fltarr(3, nf)
  cens = fltarr(3, nf)
  for i = 0L, nf - 1, 1 do begin
     v0 = verts[*, conn[4 * i + 1]]
     v1 = verts[*, conn[4 * i + 2]]
     v2 = verts[*, conn[4 * i + 3]]
     a = crossp(v1 - v0, v2 - v0) / 2.
     area[i] = sqrt(total(a^2))
     norms[*, i] = a / area[i]
     cens[*, i] = (v0 + v1 + v2) / 3.
  endfor
  
  assert, min(area) ge 0
  
  ;- interpolate the vector field onto the surface points
  ix = interpolate(x, cens[0,*], cens[1,*], cens[2,*])
  iy = interpolate(y, cens[0,*], cens[1,*], cens[2,*])
  iz = interpolate(z, cens[0,*], cens[1,*], cens[2,*])

  ;- dot product of vector with normals
  dot = ix * norms[0, *] + $
        iy * norms[1, *] + $
        iz * norms[2, *]
  
  return, total(dot * area * unit^2)
end
  
pro test

  ;- Divergence free field, and a simple box surface
  im = fltarr(30, 30, 30)
  indices, im, x, y, z & x-= mean(x) & y -= mean(y) & z -= mean(z)
  r = sqrt(x^2 + y^2 + z^2)
;  im = (abs(x) lt 10) and abs(y) lt 10 and abs(z) lt 10
  im = r lt 7
  isosurface, im, 1, vert, conn
  v = transpose([[max(vert, dim=1)], $
                    [min(vert, dim=1)]])
  bad = where(v[0,*] ne 24 and v[1,*] ne 5, ct)
  nf = n_elements(conn)/4

  testing = 0
  if testing then begin
     v1 = vert[*, conn[lindgen(nf)*4+1]]
     v2 = vert[*, conn[lindgen(nf)*4+2]]
     v3 = vert[*, conn[lindgen(nf)*4+3]]
     inds = [0,1,2]
     face = [5, 24]
     for ii = 0, 2, 1 do begin
        for jj = 0, 1, 1 do begin
           hit = where(vert[inds[ii],*] eq face[jj])
           
           plot, vert[(inds[ii] + 1) mod 3, hit], $
                 vert[(inds[ii] + 2) mod 3, hit], psym = 4
           
           hit = where(v1[inds[ii], *] eq face[jj] and $
                       v2[inds[ii], *] eq face[jj] and $
                       v3[inds[ii], *] eq face[jj], ct)
           for kk = 0, ct - 1, 1 do begin
              polyfill, [ v1[(inds[ii]+1) mod 3, hit[kk]], $
                          v2[(inds[ii]+1) mod 3, hit[kk]], $
                          v3[(inds[ii]+1) mod 3, hit[kk]]], $
                        [ v1[(inds[ii]+2) mod 3, hit[kk]], $
                          v2[(inds[ii]+2) mod 3, hit[kk]], $
                          v3[(inds[ii]+2) mod 3, hit[kk]]], $
                        color = fsc_color('red'), /line_fill, $
                        orientation =90, spacing=.1
              oplot, [ v1[(inds[ii]+1) mod 3, hit[kk]], $
                       v2[(inds[ii]+1) mod 3, hit[kk]], $
                       v3[(inds[ii]+1) mod 3, hit[kk]], $
                       v1[(inds[ii]+1) mod 3, hit[kk]]], $
                     [ v1[(inds[ii]+2) mod 3, hit[kk]], $
                       v2[(inds[ii]+2) mod 3, hit[kk]], $
                       v3[(inds[ii]+2) mod 3, hit[kk]], $
                       v1[(inds[ii]+2) mod 3, hit[kk]]], $
                     color = fsc_color('blue')
           endfor
           stop
        endfor
     endfor
     return
  endif

  vx = im * 0 + 5
  vy = im * 0
  vz = im * 0
  print, 'Divergence free field'
  print, div3(vx, vy, vz, vert, conn)

  ;- divergence = 1
  vx = x
  
  print, 'div = 1. Volume: ', mesh_volume(vert, conn)
  print, 'tetra volume:', tetra_volume(vert, conn)
  print, 'solid?', mesh_issolid(conn)
  print, 'triangles:', mesh_numtriangles(conn)
  print, 'divergence:', div3(vx, vy, vz, vert, conn)
  print, 'surface area: ', mesh_surfacearea(vert, conn)
end

