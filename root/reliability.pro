function reliability, pm, par, field = field, error = error
  dir = '~/parallax_papers/besancon/final_sims/'
  search_strings = [dir+'l90b00*far*int.sav', $
                    dir+'l180b00*far*int.sav', $
                    dir+'l180b90*far*int.sav']
  search_string = search_strings[field]
  files = file_search(search_string, count=ct)
  
  npm = n_elements(pm)
  npar = n_elements(par)
  
  comp_ct = completeness(pm, par, /net_count, field = field)
  
  sum = fltarr(npm, npar)
  sum2 = sum

  for i = 0, ct - 1, 1 do begin
     restore, files[i]
     
     npm_grid = n_elements(pmsigs)
     npi_grid = n_elements(pisigs)

     x = interpol(indgen(npm_grid), pmsigs, pm)
     y = interpol(indgen(npi_grid), pisigs, par)
     add = interpolate(interlopers, x, y) ;- srcs per square degree
     add = comp_ct / (add + comp_ct)
     assert, min(add) ge 0 and max(add) le 1
     sum += add
     sum2 += add^2
  endfor
  assert, max(sum) le ct and min(sum) ge 0
  sum /= ct
  sum2 /= ct 
  result = sum
  error = sqrt(sum2 - sum^2) / sqrt(ct) ;- denom because of clt
  ;print, result
  return, result
end

pro test

  pmsigs = arrgen(0D, 100D, 10) & npm = n_elements(pmsigs)
  pisigs = arrgen(0D, 7D, 1) & npi = n_elements(pisigs)
  pisigs2 = arrgen(0D, 7D, .5) & npi2 = n_elements(pisigs2)

  device, decomposed = 0
  window, 0, xsize = 900, ysize = 900

  
  !p.multi = [0,1,2]
  loadct, 0, /silent
  plot, [0],[1], xra = [0, 7], yra = [.05,1.01], $
        /nodata, $
        ytit = 'Reliability', charsize = 2
  loadct, 25, /silent

  for i = 0, n_elements(pmsigs) - 1, 1 do begin
     r = reliability('l90b00*_int.sav', replicate(pmsigs[i],npi2), $
                     pisigs2, error = er)
     oploterror, pisigs2, r, er * 0, er, color = 255 * i / npm, $
                 errcolor = 255 * i / npm, psym = 4
     x = arrgen(0, 7, .1)
;     spline_p, pisigs2, r, sx, sr
;     oplot, x, interpol(r, pisigs2, x, /quadratic), color = 255 * i / npm
     oplot, x, spline(pisigs2, r, x), color = 255 * i / npm
;     oplot, sx, sr, color = 255 * i / npm
  endfor


  loadct, 0, /silent
  plot, [0],[1], xra = [0, 7], yra = [.95,1.01], $
        /nodata, $
        ytit = 'Reliability', charsize = 2
  loadct, 25, /silent

  for i = 0, n_elements(pmsigs) - 1, 1 do begin
     r = reliability(replicate(pmsigs[i],npi), $
                     pisigs, error = er, field = 1)
     oploterror, pisigs, r, er * 0, er, color = 255 * i / npm, $
                 errcolor = 255 * i / npm, psym = 4
     x = arrgen(0, 7, .1)
     oplot, x, spline(pisigs, r, x), color = 255 * i / npm
  endfor

  !p.multi = 0
end
     
