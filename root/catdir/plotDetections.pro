pro plotDetections, m, t, image_id, images

  hit = where(m.image_id eq image_id, ct)
  if ct eq 0 then begin
     print, 'no matches'
     return
  endif

  ra = t[m[hit].ave_ref].ra + m[hit].d_ra / 3600D
  dec = t[m[hit].ave_ref].dec + m[hit].d_dec / 3600D

  x = m[hit].x_ccd
  y = m[hit].y_ccd

  pold = !p.multi
  !p.multi = [0,2,2]
  plotstar, ra, dec, m[hit].mag
  plotstar, x, y, m[hit].mag
  im = images[image_id - 1]
  sky2chip, ra, dec, x, y, ra, dec, x2, y2
  plot, x, x2, psym = 3
  oplot, minmax(x), minmax(x), color = fsc_color('red'), thick = 2
  plot, y, y2
  oplot, minmax(y), minmax(y), color = fsc_color('red'), thick = 2
;  plot, ra, im.crval1 + (x - im.crpix1) * im.cdelt1, psym = 4
;  plot, dec, im.crval2 + (y - im.crpix2) * im.cdelt2, psym = 4

;  plot, ra, x, psym = 4
;  oplot, ra, y, psym = 4, color = fsc_color('blue')
;  plot, dec, x, psym = 4
;  oplot, dec, y, psym = 4, color = fsc_color('blue')
  !p.multi = pold


end
