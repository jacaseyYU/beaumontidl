function completeness, pmcut, parcut, net_count = net_count, field = field, $
                       error = err
  dir = '~/parallax_papers/besancon/final_sims/'
  search_strings = dir+['l90b00_near_com.sav', $
                        'l180b00_near_com.sav', $
                        'l180b90_near_com.sav']
  search_string = search_strings[field]
  area = 1d4

  assert, file_test(search_string)
  restore, search_string

  npar = n_elements(parallax) & npm = n_elements(pm)
  grid_y = indgen(npar) & grid_x = indgen(npm)
  y = interpol(grid_y, parallax, parcut)
  x = interpol(grid_x, pm, pmcut)
  ;- default: fractional completeness
  result = interpolate(complete, x, y)
  r = result * number
;  print, 'result is ', result
  ;- optional: Number of included sources per square degree
  if keyword_set(net_count) then result *= number / area
  err = result / sqrt(r)
  return, result
end
  
pro test

  pmsigs = arrgen(0D, 100D, 10) & npm = n_elements(pmsigs)
  pisigs = arrgen(0D, 7D, 1) & npi = n_elements(pisigs)
  

  loadct, 0, /silent
  plot, [0],[1], xra = [0, 7], yra = [0,1.1], /nodata
  loadct, 25, /silent
  for j = 0, npm - 1, 1 do begin
     com = completeness(replicate(pmsigs[j], npi), pisigs)
     ;com = complete[*,j]
     oplot, pisigs, com, color = 255 * j / npm, $
            psym = 4
     rx = arrgen(0, 7, .1)
     oplot, rx, spline(pisigs, com, rx, 5), color = 255 * j / npm, thick = 2
  endfor
end
