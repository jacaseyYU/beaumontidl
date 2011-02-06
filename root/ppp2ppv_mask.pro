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
  ppp *= valid
  
  x = indgen(sz[1] * sz[2]) mod sz[1]
  y = indgen(sz[1] * sz[2]) / sz[1]

  for i = 0, sz[3] - 1 do begin
     z = x * 0 + i
     z1 = (i eq (sz[3] - 1)) ? z : z + 1
     v = ind[x, y, z]
     v1 = ind[x,y,z1]

     jump = 3 * fix(max(abs(z1 - z)) + 1)
     for j = 0, jump-1, 1 do begin
        w = 1.0 * j / jump
        val = byte(round( ppp[x, y, z] * (1 - w) + ppp[x,y,z1] * w ))
        vp = v * (1 - w) + v1 * w
        w1 = vp - floor(vp)
        result[x,y,floor(vp)] or= val
     endfor
  endfor

  return, result
end
