pro c2noncen_mc_gridgen

  lambdas = arrgen(0, 100, 1)^2
  nl = n_elements(lambdas)
  x = arrgen(0, 110, .1)^2
  nx = n_elements(x)
  grid = dblarr(nl, nx)
  xlo = lambdas
  xhi = lambdas

  nsample = 1d7
  for i = 0, nl - 1, 1 do begin
     print, i, nl
     x1 = randomn(seed, nsample) + sqrt(lambdas[i] / 2)
     x2 = randomn(seed, nsample) + sqrt(lambdas[i] / 2)
     chi2 = x1^2 + x2^2
     edf, chi2, ex, ey
     xlo[i] = min(chi2, max = hi)
     xhi[i] = hi
     lo = where(x lt xlo[i], loct)
     hi = where(x gt xhi[i], hict)

     ey2 = interpol(ey, ex, x)
     if loct ne 0 then ey2[lo] = 0
     if hict ne 0 then ey2[hi] = 1
;     oplot, x, ey2, color = fsc_color('red'), line = 2
     grid[i, *] = 1 - ey2
  endfor
  grid_x = x & grid_lambda = lambdas
  save, grid, grid_x, grid_lambda, $
        xlo, xhi, nsample, file='c2noncen_mc.sav'
end

function c2noncen_mc, x, lambda, status
  common c2noncen_mc, grid, xlo, xhi, nsample, grid_x, grid_lambda
  if n_elements(grid) eq 0 then restore, '~/pro/c2noncen_mc.sav'
;  if n_elements(triangles) eq 0 then begin
;     print, 'doing triangles'
;     nl = n_elements(grid_lambda)
;     nx = n_elements(grid_x)
;     triangulate, grid_lambda, grid_x, triangles
;     print, 'done'
;  endif

  sz = size(grid)
  nl = sz[1] & nx = sz[2]
  i_lam = interpol(indgen(nl), grid_lambda, lambda)
  i_x = interpol(indgen(nx), grid_x, x)
  result = interpolate(grid, i_lam, i_x)

  status = byte(result * 0)
  
  ;- special cases 1-2: Falls outside of xlo or xhi
  bad = where(lambda ge 5d-3 and $
              lambda le max(grid_lambda) and $
              x lt interpol(xlo, grid_lambda, lambda), badct) 
  if badct ne 0 then begin
     result[bad] = 1
     status[bad] = 1
  endif
  bad = where(lambda ge 5d-3 and $
              lambda le max(grid_lambda) and $
              x gt interpol(xhi, grid_lambda, lambda), badct)
  if badct ne 0 then begin
     result[bad] = 0
     status[bad] = 2
  endif

  ;- special case 3: lambda is too large
  ;- approximate with the normal distribution. CLT, maybe? 
  bad = where(status eq 0 and $
              lambda gt max(grid_lambda), badct)
  if badct ne 0 then begin
     status[bad] = 3
     mean = 2 + lambda[bad]
     var = 2 * (2 + 2 * lambda[bad])
     result[bad] = 1 - gauss_pdf((x[bad] - mean) / sqrt(var))
  endif
  
  ;- special case 4: Lambda is very small. chisqr_pdf is better
  ;- here, since it tracks probabilities down to 10^-16
  bad = where(status eq 0 and $
              lambda lt 5d-3, badct)
  if badct ne 0 then begin
     status[bad] = 4
     result[bad] = 1 - chisqr_pdf(x[bad], 2)
  endif

  return, result
end

pro test
  restore, 'c2noncen_mc.sav'
  ind = 5
  x = grid_x
  y = x * 0 + grid_lambda[ind]

  plot, x, grid[ind,*], xra = [0, 100]
  
  y2 = c2noncen_mc(x, y+1, status)
  print, status
  oplot, x, y2, color = fsc_color('red'), line=2
end
