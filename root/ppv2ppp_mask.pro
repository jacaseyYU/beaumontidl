function ppv2ppp_mask, ppv, vel, bincenters
  compile_opt idl2
  
  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppv2ppp_mask(ppp, vel, bincenters)'
     return, !values.f_nan
  endif

  sz = size(ppv)
  if sz[0] ne 3 then $
     message, 'ppv must be a data cube'
  
  sv = size(vel)
  if sv[0] ne 3 then $
     message, 'vel must be a data cube'

  if sz[3] ne sv[dimension] then $
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
  v = (vel - bincenters[0]) / (binsize[0])
  
  return, (ppv[x, y, v] ne 0) and (v ge 0) and (v le sz[2])
end
