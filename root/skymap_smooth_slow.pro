pro skymap_smooth_slow, map, x, y, val, dval, $
                   fwhm = fwhm, $
                   truncate = truncate, $
                   emap = emap
  
  if ~keyword_set(truncate) then truncate = !values.f_infinity
  nobj = n_elements(x)

  sigma = fwhm / (2 * sqrt(2 * alog(2)))

  result = map.map * 0
  weight = result
  weight2 = result
  var = result

  ;- map pixels to sky coords
  nx = sxpar(map.head, 'naxis1')
  ny = sxpar(map.head, 'naxis2')
  mx = rebin(findgen(nx), nx, ny)
  my = rebin(1#findgen(ny), nx, ny)
  xyad, map.head, mx, my, ma, md

  ;- data sky coords to pixels
  da = x
  dd = y
  adxy, map.head, da, dd, dx, dy

  ;- a postage stamp
  ;- safely calculate minimum pixel size (may be variable)
  delt = (ma - shift(ma, 1,0)) > (md - shift(md, 0,1))
  delt[0,*] = !values.f_infinity & delt[*,0] = !values.f_infinity
  delt = min(delt) ;- degrees per pixel
  stampsz = ceil(truncate / delt) + 1
  
  ;- stamp pixel coords
  sx = rebin(indgen(stampsz) - stampsz / 2, stampsz, stampsz)
  sy = rebin(1#indgen(stampsz) - stampsz / 2, stampsz, stampsz)
  
  ;- loop over sources, vectorize on pixels
  for i = 0, nobj - 1, 1 do begin
     ;x = floor(sx + dx[i])
     ;y = floor(sy + dy[i])
     ;xyad, map.head, x, y, sa, sd
     ;gcirc, 2, da[i], dd[i], sa, sd, dis
     gcirc, 2, da[i], dd[i], ma, md, dis
     dis /= 3600.
     w = 1/dval[i]^2 * exp(-dis^2 / (2 * sigma)^2) * (dis lt truncate)
     top = max(w, loc)
;     print, i, mx[loc], my[loc]
     ;- where do we put the postage stamp down?
     ;l = min(x) > 0        & sl = l - min(x)
     ;r = max(x) < (nx - 1) & sr = stampsz - 1 + (r - max(x)) 
     ;b = min(y) > 0        & sb = b - min(y)
     ;t = max(y) < (ny - 1) & st = stampsz - 1 + (t - max(y))
     ;assert, r - l eq sr - sl
     ;assert, t - b eq st - sb

     ;- update the maps
     result += w * val[i]
     weight += w
     var += w * dval[i]^2
     weight2 += w^2
;     result[l:r, b:t] += w[sl:sr, sb:st] * val[i]
;     weight[l:r, b:t] += w[sl:sr, sb:st]
;     var[l:r, b:t] += w[sl:sr, sb:st]^2 * dval[i]^2
;     w2[l:r, b:t] += w[sl:sr, sb:st]^2
  endfor

  result /= weight
  emap = var / weight2

  bad = where(~finite(result), ct)
  if ct ne 0 then begin
     result[bad] = !values.f_nan
     emap[bad] = !values.f_nan
  endif
  map.map = result
  return

end
  
