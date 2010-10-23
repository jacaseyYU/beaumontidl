function sourcepos, date, object, ra = ra, dec = dec, galactic = galactic
  compile_opt idl2
  on_error, 2

  if n_elements(object) ne 0 && n_elements(ra) eq 0 then begin
     querysimbad, object, x, y, found = found, errmsg = errmsg
     if found ne 1 then message, 'Could not find object in SIMBAD'
  endif else begin
     if keyword_set(galactic) then euler, ra, dec, x, y, 2 $
     else begin
        x = ra & y = dec
     endelse
  endelse
  ;- MAUNA KEA location
  lon = -155.472
  lat = 19.826
  alt = 4215.
  tz = 10.

  ;- convert date to JD time
  if strlen(date) ne 8 then message, $
     'date must be in the format YYYYMMDD'
  year = fix(strmid(date, 0, 4))
  month = fix(strmid(date, 4, 2))
  day = fix(strmid(date, 6, 2))
 
  
  juldate, [year, month, day, 10, 0, 0], jd0
  jd = arrgen(jd0, jd0+1, nstep = 240) +2.4d6;- steps of 10 minutes 
  njd = n_elements(jd)
  hour = arrgen(0., 24., nstep = njd)
  x = replicate(x, njd) & y = replicate(y, njd)

  ;- convert from RA, DEC, to ALT, AZ
  eq2hor, x, y, jd, alt, az, lat = lat, lon = lon

  return, transpose([[hour], [alt], [az]])

  plot, hour, alt, /nodata, yra = [0, max(alt)]
  color = (alt lt 0) * 0 + (alt ge 0 and alt lt 30) * 1 + (alt ge 30) * 2
  cs = ['red', 'yellow', 'green']
  color = cs[color]
  color = fsc_color(color)
  for i = 0, n_elements(alt) - 2 , 1 do $
     oplot, hour[i:i+1], alt[i:i+1], color = color[i]
end
  
  
