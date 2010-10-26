pro object_bounds, objs, xrange, yrange, zrange

  if n_params() eq 0 then begin
     print, 'Calling sequence:'
     print, ' object_bounds, objs, xrange, yrange, zrange'
     return
  endif

  xrange=[!values.f_infinity, -!values.f_infinity]
  yrange=[!values.f_infinity, -!values.f_infinity]
  zrange=[!values.f_infinity, -!values.f_infinity]

  for i = 0, n_elements(objs) - 1, 1 do begin
     o = objs[i]
     if ~obj_valid(o) then continue
     case 1 of
        obj_isa(o, 'IDL_CONTAINER'): begin
           children = o->get(/all)
           object_bounds, children, xr, yr, zr
           xrange=[xrange[0] < xr[0], xrange[1] > xr[1]]
           yrange=[yrange[0] < yr[0], yrange[1] > yr[1]]
           zrange=[zrange[0] < zr[0], zrange[1] > zr[1]]
        end
        obj_isa(o, 'IDLGRPLOT') || obj_isa(o, 'IDLGRPOLYGON'): begin
           o->getProperty, xrange = xr, yrange = yr, zrange = zr
           xrange=[xrange[0] < xr[0], xrange[1] > xr[1]]
           yrange=[yrange[0] < yr[0], yrange[1] > yr[1]]
           zrange=[zrange[0] < zr[0], zrange[1] > zr[1]]
        end
        else:
     endcase
  endfor
end

pro test
  x = obj_new('idlgrplot', findgen(20), findgen(20))
  isosurface, rebin(dist(30), 30, 30, 30), 10, v, c
  y = obj_new('idlgrpolygon', v, poly = c)
  object_bounds, x, xra, yra, zra
  print, 'expecting 0-19, 0-19, 0-0'
  print, xra, yra, zra

  object_bounds, y, xra, yra, zra
  xr2 = minmax(v[0,*])
  yr2 = minmax(v[1,*])
  zr2 = minmax(v[2,*])
        
  fmt='("calc: ", 2(f0.1, 2x), "actual: ", 2(f0.1, 2x))'
  print, xra, xr2, format = fmt
  print, yra, yr2, format=fmt
  print, zra, zr2, format=fmt

  m = obj_new('idlgrmodel')
  m->add, x
  m->add, y
  object_bounds, m, xra, yra, zra
  print, xra, yra, zra

end
