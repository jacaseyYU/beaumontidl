function r, theta, n

  theta0 = -20 * !dtor 
  r0 = 2.1
  p = 12.8 * !dtor
  m = 4D
  r = exp((theta - theta0 + 2 * !dpi * (n - 1) / m) * tan(p)) * r0
  bad = where(r lt 3, bct)
  if bct ne 0 then r[bad] = !values.f_nan
  return, r
end

pro galaxymap
  compile_opt idl2
  rsun = 7.6
  
  theta = arrgen(-720, 720, 1) * !dtor
  r1 = r(theta, 1)
  r2 = r(theta, 2)
  r3 = r(theta, 3)
  r4 = r(theta, 4)
  thk = 10
  plot, r1 * cos(theta), r1 * sin(theta), xra = [-10, 10], yra = [-10, 15], /nodata
  oplot, r1 * cos(theta), r1 * sin(theta), color = fsc_color('red'), thick=thk
  oplot, r2 * cos(theta), r2 * sin(theta), color = fsc_color('blue'), thick=thk
  oplot, r3 * cos(theta), r3 * sin(theta), color = fsc_color('green'), thick=thk
  oplot, r4 * cos(theta), r4 * sin(theta), color = fsc_color('yellow'), thick=thk

 
  csz = 2 & ctk = 2

  xyouts, 2.4, 4.3, 'Scutum', /data, charsize = csz, charthick = 2, $
          ori = -45

  xyouts, 3, 6, 'Sagittarius', /data, charsize = csz, charthick = 2, $
          ori = -45

  xyouts, 5, 8, 'Perseus', /data, charsize = csz, charthick = 2, $
          ori = -45

  xyouts, 7, 11, 'Cygnus', /data, charsize = csz, charthick = 2, $
          ori = -45


  xyouts, -4.6, 1.5, 'Norma', /data, charsize = csz, charthick = 2, $
          ori = 40

  xyouts, -5.6, 3, 'Crux', /data, charsize = csz, charthick = 2, $
          ori = 40

  xyouts, -7, 5, 'Carina', /data, charsize = csz, charthick = 2, $
          ori = 30


  oplot, [0], [rsun], psym = symcat(16), symsize = 3

  x = arrgen(0D, 10,.2)
  l = 15 * !dtor
  oplot, x * sin(l), rsun - x * cos(l), thick = 3
  x = [1, 2, 3, 4, 5]
  oplot, x * sin(l), rsun - x * cos(l), thick = 3, psym = symcat(16), symsize = 2
end 
