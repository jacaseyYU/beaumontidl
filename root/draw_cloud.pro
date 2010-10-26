pro draw_cloud
  
  restore, '~/pro/iso.sav'
  m = fltarr(50,50,50) & indices, m, x, y, z
  r = sqrt((x-25)^2 + (y-25)^2 + (z-25)^2)
;  isosurface, r, 7, v, c
  isosurface, r, 4, v2, c2

  top = obj_new('idlgrmodel')
  group = obj_New('idlgrmodel')
  top->add, group

  v[0,*] -= median(v[0,*])
  v[1,*] -= median(v[1,*])
  v[2,*] -= median(v[2,*])
;  v2[0,*] -= median(v2[0,*])
;  v2[1,*] -= median(v2[1,*])
;  v2[2,*] -= median(v2[2,*])

  xra = minmax(v[0,*]) & yra = minmax(v[1,*]) & zra = minmax(v[2,*])
;  xc = [-.5, 1.0 / range(xra)]
;  yc = [-.5, 1.0 / range(yra)]
;  zc = [-.5, 1.0 / range(zra)]

  obj = obj_new('idlgrpolygon', v, poly = c, color=[255,0,0], $
                xcoord_c = xc, ycoord_c = yc, zcoord_c = zc, $
                shading=1, $ ;- 1=smooth surfaces
                style = 2, $ ;- 0=points 1=lines 2=surfaces
                alpha=.5, /depth_test_disable $
                )
  o2 = obj_new('idlgrpolygon', v2, poly = c2, color = [0,0,255], $
               shading = 1, style = 2, alpha = .5, /depth_test_disable)

  obj->getProperty, xrange = xra2
  print, 'xrange', xra, xra2
  
  group->add, obj
  group->add, o2

  light = obj_new('idlgrlight', location=[xra[1], yra[1], zra[1]], type=1)
  top->add, light
  light = obj_new('idlgrlight', type = 0, intensity = 0.5)
  top->add, light

  
  print, zra
  win = obj_new('pzwin', top, /standalone, /rotate, zrange = [50, -50])
end
