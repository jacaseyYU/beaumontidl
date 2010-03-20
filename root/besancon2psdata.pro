function besancon2psdata, besancon, optimistic = optimistic, $
                          av = av, cut = cut, $
                          addnoise = addnoise, fix_distance = fix_distance
  compile_opt idl2
  common besancon2psdata_random, seed

  num = n_elements(besancon)

  ;- Pan-STARRS IQ parameters
  ;- Numbers based on 3 pi data, from Dupuy et al. 2009
  flux0 = 10^(-[23.4, 22.8, 22.2, 21.6, 20.1]/2.5)
  flux_sat = 10^(-[15.6, 15.3, 14.8, 14.4, 12.8]/2.5)
  exp_time = [60D, 38, 30, 30, 30]
  sky_flux = [6.9, 22.5, 48.7, 77.6, 89.6]          ;- sky photon flux per m^2 "^2
  area = 1.73                                       ;- m^2
  fwhm = 0.8                                        ;- arcseconds
  zero_point = [4.73, 5.87, 5.55, 3.78, 1.85] * 1d9 ;- photon flux of a zero mag source
  flux_frac = .5                                    ;- fraction of source photons collected in aperture
  sky_flux = sky_flux * !pi * fwhm^2 / 4.           ;- photons / sec

  sn0 = 5D
  n_epoch = 12. * 0.8
  baseline = 3.5
  max_snr = 100                 ;- mag
  ast_floor = .010D             ;- arcsec
  psf   = .8 / 2.355            ;- fwhm to sigma
  flux_noise = randomn(seed, 5, num)
  mu_noise = randomn(seed, 2, num)
  pi_noise = randomn(seed, num)

  ;- get the spectral types, and convert to panstarrs colors
  class = besancon.CL
  type = besancon.typ
  subtype = type mod 1
  subtype = floor(subtype * 10) / 10 ;- psstarcolor only has one sig fig
  type = floor(type)
  normal = where(type le 7)
  agb    = where(type eq 8, agbct)
  wd     = where(type eq 9, wdct)
  sz = n_elements(besancon)
  g = fltarr(sz)
  r = g & i = g & z = g & y = g

  colors = psstarcolor(type[normal]-1, subtype[normal], class[normal])
  csz = size(colors)
  assert, csz[2] eq n_elements(normal) && csz[1] eq 4
  assert, max(besancon.av) eq 0
  g = besancon.u - besancon.ug
  r[normal] = g[normal] - colors[0, *]
  i[normal] = r[normal] - colors[1, *]
  z[normal] = i[normal] - colors[2, *]
  y[normal] = z[normal] - colors[3, *]
  pi = 1 / besancon.dist / 1d3
  
  ;XXX need to handle WDs, AGBs 
  ;for now, just assume AGBs have the colors of an M5 star
  if agbct ne 0 then begin
     colors = psstarcolor(replicate(6,agbct), $
                          replicate(5,agbct), $
                          replicate(1,agbct))
     r[agb] = g[agb] - colors[0, *]
     i[agb] = r[agb] - colors[1, *]
     z[agb] = i[agb] - colors[2, *]
     y[agb] = z[agb] - colors[3, *]
  endif

  ;for now, assume wd emits like a blackbody for ps colors
  if wdct ne 0 then begin
     colors = psbbcolor(10^(besancon[wd].ltef))
     r[wd] = g[wd] - colors[0, *]
     i[wd] = r[wd] - colors[1, *]
     z[wd] = i[wd] - colors[2, *]
     y[wd] = z[wd] - colors[3, *]
  endif

  ;- fix all distances at 100 pc, if requested
  if keyword_set(fix_distance) then begin
     delta = 5 * alog10(.1 / besancon.dist)
     g += delta
     r += delta
     i += delta
     z += delta
     y += delta
  endif

  ;- add in reddening
  if keyword_set(av) then begin
     av = besancon.dist * .7                 ;- mags of Av extinction
     if keyword_set(fix_distance) then av = av * 0 + .07
     ps_lam_inv = 1/[.484, .621, .754, .869, .979] ;- 1/eff lambda. Dupuy
     ;- reddening from Cardelli Clayton Mathis 89
     ref_lam_inv=[2.27, 1.82, 1.43, 1.11, 0.80, 0.63, 0.46]
     ref_a = [1.337, 1.000, 0.751, 0.479, 0.282, 0.190, 0.114]
     a_lam = interpol(ref_a, ref_lam_inv, ps_lam_inv)
     g += av * a_lam[0]
     r += av * a_lam[1]
     i += av * a_lam[2]
     z += av * a_lam[3]
     y += av * a_lam[4]
  endif

  ;- add flux noise
  snr = transpose([[psmag2snr(g, 0, ast = gast)], $
                   [psmag2snr(r, 1, ast = rast)], $
                   [psmag2snr(i, 2, ast = iast)], $
                   [psmag2snr(z, 3, ast = zast)], $
                   [psmag2snr(y, 4, ast = yast)]])

  flux = transpose([[g], [r], [i], [z], [y]])
  flux = 10^(-flux / 2.5)      

  is_detected = total(snr gt 5, 1) ne 0
  is_saturated = flux gt rebin(flux_sat, 5, num)
  bad = where(is_saturated, badct)
  if badct ne 0 then snr[bad] = 1d-3
  flux_err = flux / snr / sqrt(n_epoch)
  if keyword_set(addnoise) then flux += flux_noise * flux_err
  if badct ne 0 then flux[bad] = !values.f_nan

  ;- add astrometry noise
  ast_err = transpose([[gast],[rast],[iast],[zast],[yast]])
  ast_err *= sqrt(5. / n_epoch)
  nobs = total(finite(ast_err), 1)
  assert, max(nobs) eq 5
  if badct ne 0 then ast_err[bad] = !values.f_nan
  ast_err = sqrt(1 / total(1 / ast_err^2, 1,/nan))

  if keyword_set(optimistic) then begin
     ast_err /= sqrt(5. / nobs)
  endif
  
  assert, n_elements(ast_err) eq n_elements(besancon)
  
  pi_err = ast_err
  if keyword_set(addnoise) then pi += pi_noise * pi_err ;- in arcsec
  mu_err = pi_err / baseline * 1d3 ;- in mas
  mux = besancon.mux * 10D + mu_err * mu_noise[0,*] * (keyword_set(addnoise) ? 0 : 1)
  muy = besancon.muy * 10D + mu_err * mu_noise[1,*] * (keyword_set(addnoise) ? 0 : 1)
  if keyword_set(fix_distance) then begin
     mux *= (besancon.dist / .1)
     muy *= (besancon.dist / .1)
     pi *= (besancon.dist / .1)
  endif

  if keyword_set(cut) then begin
     good = where(is_detected and (total(~is_saturated, 1) ne 0), goodct)
     if goodct eq 0 then begin
        message, /continue, 'No objects were detected'
        return, !values.f_nan
     endif
    
     result = replicate({psdata}, goodct)
     result.l = besancon[good].l
     result.b = besancon[good].b
     besancon = besancon[good]
     result.pi = pi[good]
     result.sigma_pi = pi_err[good]
     result.flux = flux[*,good]
     result.sigma_flux = flux_err[*,good]
     result.mux = mux[good]
     result.muy = muy[good]
     result.mu = sqrt(result.mux^2 + result.muy^2)
     result.sigma_mu = mu_err[good]
  endif else begin
     result = replicate({psdata}, num)
     result.l = besancon.l
     result.b = besancon.b
     result.pi = pi
     result.sigma_pi = pi_err
     result.flux = flux
     result.sigma_flux = flux_err
     result.mux = mux
     result.muy = muy
     result.mu = sqrt(mux^2 + muy^2)
     result.sigma_mu = mu_err
  endelse

  return, result
end
