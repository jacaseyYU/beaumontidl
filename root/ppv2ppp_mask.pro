function ppv2ppp_mask, ppv, vel, bincenters
  compile_opt idl2
  
  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppv2ppp_mask(ppv, vel, bincenters)'
     return, !values.f_nan
  endif

  sz = size(ppv)
  if sz[0] ne 3 then $
     message, 'ppv must be a data cube'
  
  sv = size(vel)
  if sv[0] ne 3 then $
     message, 'vel must be a data cube'

  if sz[3] ne sv[3] then $
     message, 'ppv cube and velocity field have incompatible sizes'

  if n_elements(bincenters) ne sz[3] then $
     message, 'bincenters has an incorrect number of elements'

  binsize = bincenters - shift(bincenters, 1)
  binsize[0] = binsize[1]
  if abs(range(binsize) / mean(binsize)) gt 1d-2 then $
     message, 'bincenters are not uniformly spaced'
  binsize = binsize[0]

  nbin = n_elements(bincenters)

  indices, vel, x, y, z
  v = round((vel - bincenters[0]) / (binsize))
  
  return, (ppv[x, y, v < (sz[3] - 1)] ne 0) and (v ge 0) and (v lt sz[3])
end


pro test
  ppv = bytarr(2, 2, 100)
  ppv[*,*, 20:40] = 1
  indices, ppv, x, y, z
  vel = float(z)

  !p.multi = [0,1,2]
  v = indgen(100) / 2.
  ppp = ppv2ppp_mask(ppv, vel, v)
  plot, ppp[1,1,*], yra = [0, 1.5]
  oplot, vel[1,1,*] gt v[20] and vel[1,1,*] lt v[40], $
         color = fsc_color('red'), line = 2

  vel = sin(z / 10.) * 30
  ppp = ppv2ppp_mask(ppv, vel, v)
  plot, ppp[1,1,*], yra = [0, 1.5], psym = -4
  oplot, vel[1,1,*] gt v[20] and vel[1,1,*] lt v[40], $
         color = fsc_color('red'), line = 2


  !p.multi = 0
end
