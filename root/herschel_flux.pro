function herschel_flux, x, ncol = ncol, temp = temp, $
                        desert = desert, dupac = dupac, beta = beta

  ;- if x is supplied, take parameters from there
  if n_elements(x) ne 0 then begin
     ncol = x[0]
     temp = x[1]
     beta = x[2]
  endif

  ;- herschel observing wavelengths, and default beta=2 opacity
  lambda = [70., 170, 250, 350, 500] ;- microns
  kappa = mass_opacity(lambda, model=3)
  freq = apcon('c') / (lambda * 1d-4) ;- hz

  sigma = ncol * (2.36 * apcon('m_proton')) ;- surface density, cgs

  ;- a specific opacity model is requested
  if keyword_set(desert) then begin
     beta = 11.5 * temp^(-0.66)
     kappa = kappa[2] * (lambda/lambda[2])^(-beta)
  endif else if keyword_set(dupac) then begin
     beta = 1 / (.04 + .008 * temp)
     kappa = kappa[2] * (lambda/lambda[2])^(-beta)
  endif else if keyword_set(beta) then begin
     kappa = kappa[2] * (lambda/lambda[2])^(-beta)
  endif

  flux_dens = blackbody(temp, freq, /cgs) * kappa * sigma
  result = flux_dens / apcon('jy') / 1d6 ;- MJy / steradian
  return, result
end


pro test
  
  grid = 50
  ncol = arrgen(1d19, 1d24, nstep = grid, /log)
  temp = arrgen(0, 100, nstep = grid)
  flux = fltarr(5, grid, grid)

  for i = 0, grid - 1, 1 do begin
     for j = 0, grid - 1, 1 do begin
        flux[*,i,j] = herschel_flux(ncol = ncol[i], temp = temp[j])
     endfor
  endfor
  !p.multi = [0,3,2]
  limits = [12.2, 5.4, 2.18, 1.09, 0.67]
  lev = arrgen(1d-2, 1d3, nstep = 6, /log)
  snr = replicate(!values.f_infinity, grid, grid)

  for i = 0, 4, 1 do begin
     contour, flux[i,*,*], ncol, temp, /xlog, lev = lev, c_label = replicate(1, 6), $
              charsize= 3.5, c_charsize = 1.5, xtit='N_H (cm^-2)', ytit='T (K)'
     contour, flux[i,*,*], ncol, temp, /over, lev=5*limits[i], c_color = fsc_color('red')
     snr = snr < flux[i,*,*]
  endfor
     contour, snr, ncol, temp, /xlog, lev = [1, 5, 10, 100], c_label = replicate(1, 4), $
              charsize= 3.5, c_charsize = 1.5, xtit='N_H (cm^-2)', ytit='T (K)', $
              c_color = fsc_color(['white', 'red', 'white', 'white'])

  !p.multi = 0
  return

  lambda = [70, 170, 250, 350, 500]
  noise = [12.2, 5.4, 2.18, 1.09, 0.67]

  flux = herschel_flux(ncol = ncol, temp = temp)
  plot, lambda, flux, psym = 4, xra = [0, 600]
  oploterror, lambda, flux, flux * 0, noise, psym = 4

  l = arrgen(70, 500, nstep = 100) * 1d-4
  f = apcon('c') / l
  bb = blackbody(temp, f, /cgs)
  bb = bb / interpol(bb, l, 250d-4) * flux[2]
  bb2 = interpol(bb, l/1d-4, lambda)
  print, abs(bb2 - flux) / flux
;  print, minmax(bb)
;  oplot, l / 1d-4, bb, /line
end
