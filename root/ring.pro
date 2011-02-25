pro ring, xcen, ycen, maj, min, theta, thick, vert, conn, npt = npt
  if n_params() ne 8 then begin
     print, 'calling sequence'
     print, 'ring, xcen, ycen, maj, min, theta, thick, vert, conn, [npt = npt]'
     return
  endif

  if ~keyword_set(npt) then npt = 300
  th = arrgen(0., 2 * !pi, nstep = npt)

  i = maj * cos(th)
  j = min * sin(th)
  x = i * cos(theta) - j * sin(theta)
  y = i * sin(theta) + j * cos(theta)

  i = (maj + thick) * cos(th)
  j = (min + thick) * sin(th)
  x2 = i * cos(theta) - j * sin(theta)
  y2 = i * sin(theta) + j * cos(theta)

  x = [x, x2] + xcen
  y = [y, y2] + ycen
  
  c = lonarr(5 * (npt - 1))
  for i = 0, npt - 2, 1 do $
     c[5 * i : 5*i+4] = [4, i, i+1, i + 1 + npt, i + npt]
  
  vert = transpose([[x], [y]])
  conn = c
end

pro test

  m = obj_new('idlgrmodel')
  v = obj_new('idlgrview', viewplane_rect = [-5, -5, 10, 10])

  ring, 0, 0, 3, 1, !pi / 4, .2, vert, c
  help, vert, c
  plot, vert[0,*], vert[1,*]
;  return
  p = obj_new('idlgrpolygon', vert, poly = c)

  w = obj_new('idlgrwindow')
  m->add, p
  v->add, m

  w->draw, v
  wait, 5
  obj_destroy, [v,m,w]
end
  
