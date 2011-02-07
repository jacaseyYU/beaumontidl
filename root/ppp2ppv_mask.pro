function ppp2ppv_mask, ppp, vel, bincenters

  compile_opt idl2
  
  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppp2ppv(ppp, vel, bincenters)'
     return, !values.f_nan
  endif

  sz = size(ppp)
  if sz[0] ne 3 then $
     message, 'ppp must be a data cube'
  
  if n_elements(vel) ne n_elements(ppp) then $
     message, 'ppp and vel must be the same size'

  binsize = bincenters - shift(bincenters, 1)
  binsize[0] = binsize[1]
  if abs(range(binsize) / mean(binsize)) gt 1d-2 then $
     message, 'bincenters are not uniformly spaced'
  binsize = binsize[0]

  nbin = n_elements(bincenters)  
  result = bytarr(sz[1], sz[2], nbin)

  ind = floor((vel - (bincenters[0] - binsize/2.)) / binsize)
  valid = (ind ge 0) and (ind lt n_elements(bincenters))
  mask = (ppp ne 0 and valid)
  
  x = indgen(sz[1] * sz[2]) mod sz[1]
  y = indgen(sz[1] * sz[2]) / sz[1]

  for i = 0, sz[3] - 1 do begin
     z = x * 0 + i
     z1 = (i eq (sz[3] - 1)) ? z : z + 1
     v = ind[x, y, z]
     v1 = ind[x,y,z1]

     jump = 3 * fix(max(abs(v1 - v)) + 1)
     for j = 0, jump-1, 1 do begin
        w = 1.0 * j / jump
        val = mask[x,y,z] * (w lt .5) + mask[x,y,z1] * (w ge .5)
        assert, size(val, /type) eq 1
        vp = v * (1 - w) + v1 * w
        result[x,y,floor(vp)] or= val
     endfor
  endfor

  return, result
end


pro test
  ppp = bytarr(2, 2, 100)
  ppp[*,*, 20:40] = 1
  indices, ppp, x, y, z
  vel = float(z)

  !p.multi = [0,2,2]
  v = indgen(5000) / 100.
  ppv = ppp2ppv_mask(ppp, vel, v)
  plot, v, ppv[1,1,*], yra = [0,1.5]
  oplot, v, (v gt 20 and v lt 40), color = fsc_color('red'), line = 2

  vel = z * 2.
  ppv = ppp2ppv_mask(ppp, vel, v)
  plot, v, ppv[1,1, *], yra = [0, 1.5]
  oplot, v, (v gt 40 and v lt 80), color = fsc_Color('red'), line = 2
  

  vel = (z mod 5)
  ppv = ppp2ppv_mask(ppp, vel, v)
  plot, v, ppv[1,1,*], yra = [0, 1.5]
  oplot, v, (v gt 0 and v lt 5), color = fsc_color('red'), line = 2
  !p.multi = 0
end



  
  
  
