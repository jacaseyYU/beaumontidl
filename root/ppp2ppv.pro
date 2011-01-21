function ppp2ppv, ppp, vel, bincenters, dimension = dimension
  compile_opt idl2

  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppp2ppv(ppp, vel, bincenters, [dimension = dimension])'
     return, !values.f_nan
  endif

  if ~keyword_set(dimension) then dimension = 3
  
  if dimension lt 1 || dimension gt 3 then $
     message, 'dimension must be 1, 2, or 3'

  sz = size(ppp)
  if sz[0] ne 3 then $
     message, 'ppp must be a data cube'
  
  if n_elements(vel) ne n_elements(ppp) then $
     message, 'ppp and vel must be the same size'


  binsize = bincenters - shift(bincenters, 1)
  binsize[0] = binsize[1]
  if abs(range(binsize) / mean(binsize)) gt 1d-5 then $
     message, 'bincenters are not uniformly spaced'
  binsize = binsize[0]

  nbin = n_elements(bincenters)
  
  case dimension of
     1: data = transpose(ppp, [1, 2, 0])
     2: data = transpose(ppp, [0, 2, 1])
     3: data = ppp
  endcase

  sz = size(data)
  result = dblarr(sz[1], sz[2], nbin)

  ind = floor((vel - (bincenters[0] - binsize/2.)) / binsize)
  print, minmax(ind), minmax(vel), minmax(bincenters)
  valid = (ind gt 0) and (ind lt n_elements(bincenters))
  data *= valid

  indices, reform(data[*,*,0]), x, y
  for i = 0, sz[3] - 1 do $
     result[x, y, ind[x, y, x*0 + i] ] += data[x, y, x*0 + i]
  return, result
end
