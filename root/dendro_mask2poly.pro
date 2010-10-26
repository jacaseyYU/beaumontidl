function dendro_mask2poly, mask, colors = incolors, _extra = extra
  colors = bytarr(3, 8)
  if keyword_set(incolors) then begin
     sz = size(incolors)
     if sz[0] ne 2 || sz[1] ne 3 then $
        message, 'colors must be a [3,n] array'
     if sz[2] gt 8 then $
        message, 'must specify <= 8 colors'
     colors[*, 0:sz[2]-1] = incolors
     if sz[2] lt 8 then colors[*, sz[2]:*] = rebin([255,0,0], 3, 8-sz[2])
  endif  

  if max(mask) eq 0 then $
     message, 'Mask is zero'

  ;- 8 possibles masks
  nmask = 8
  for i = 0, nmask - 1, 1 do begin
     m = (mask and ishft(1, i)) ne 0
     if max(m) eq 0 then continue
     isosurface, m, 1, v, c
     nv = n_elements(v[0,*])
     nc = n_elements(c) 
     inds = lindgen(nc / 4) * 4

     ;- append vertex list
     nvert = n_elements(vert) eq 0 ? 0 : n_elements(vert[0,*])
     vert = n_elements(vert) eq 0 ? v : [[vert], [v]]

     ;- add offset to connectivity list
     c[inds+1] += nvert
     c[inds+2] += nvert
     c[inds+3] += nvert
     conn = append(conn, c)
     
     ;- update vertex colors
     print, colors[*,i], nv
     newc = rebin(colors[*,i], 3, nv)
     if n_elements(col) eq 0 then $
        col = newc $
     else $
        col = [[col], [newc]]     
  endfor

  ;- make the idlgrpolygon object
  newv = mesh_smooth(vert, conn, lambda = .1)
  result = mesh_decimate(newv, conn, newc)
  result = obj_new('idlgrpolygon', newv, poly = newc, $
                   vert_colors = col, _extra = extra)
  return, result
end

pro test

  m = bytarr(50, 50, 50)
  indices, m, x, y, z
  r = sqrt((x-25.)^2 + (y-25.)^2+(z-25.)^2)
  r2 = sqrt((x - 10.)^2 + (y-10.)^2 + (z-10.)^2)
  m or= (r gt 10) * ishft(1, 0)
  m or= (r gt 15) * ishft(1, 1)
;  colors = [[255,0,0], [0,255,0]]
  colors=[[0,255,0],[255,0,0]]
  print, colors
  o = dendro_mask2poly(m, colors = colors, alpha = .2, shading=0, /depth_test_dis)
  o->getProperty, vert_colors = vc, data = d
  o->setProperty, color=[0,0,255]
  help, vc, d
  plot, vc[0,*]
  oplot, vc[1,*], /line
  help, vc
  xobjview, o
end
