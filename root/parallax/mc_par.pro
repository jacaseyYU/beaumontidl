;+ run fit_pmpar many times, empirically find distribution of parallax
;and pm. compare to estimated uncertainties
pro mc_par

  nobs = 10D 
  baseline = 4D
  ra = ten(6, 52, 56.8) * 15
  dec = ten(0, -24, 17.9)
  tbase = 3.5 * 365.25
  niter = 10000

  j2000 = 2451545.0D
  delta = replicate(1, nobs) * (tbase / nobs)
;  delta = 2 * randomu(seed, nobs) * (tbase /nobs)
  jd = j2000 + total(delta, /cumul)
  baseline = range(jd) / 365.25
  
  par_factor, ra, dec, jd, pr, pd
  
  noise = arrgen(1D, 30, nstep = niter) / 36d5

  fits = replicate({parfit}, niter)
  dpi = replicate(0., niter)
  for i = 0L, niter - 1, 1 do begin
     noisevec = replicate(noise[i], nobs)

     ravec = ra + randomn(seed, nobs) * noise[i]   ; + pr / 36d5 * 10
     decvec = dec + randomn(seed, nobs) * noise[i]; - pd / 36d5 * 100
     fits[i] = fit_pmpar(jd, ravec, decvec, noisevec, noisevec)
     dpi[i] = sqrt(fits[i].covar[4,4])
  endfor
  plot, noise * 36d5, dpi
;  oplot, minmax(noise/noise[0]), minmax(noise/noise[0]), color = fsc_color('red')
  a = linfit(noise * 36d5, dpi) & print, a
  b = linfit(noise * 36d5, sqrt(fits.covar[1,1])) & print, b
  b = linfit(noise * 36d5, sqrt(fits.covar[3,3])) & print, b
  
  print, 1.333 / sqrt(nobs), 3.43 / sqrt(nobs) / baseline
  oplot, noise * 36d5, noise / sqrt(nobs - 3) * sqrt(3 / 2.) * 36d5, color = fsc_color('red')
  ;return
  print, mean(dpi), noise / sqrt(nobs) * sqrt(5) / sqrt(2) * 36d5
  print, mean(dpi), stdev(dpi)
  h = histogram(fits.ura / sqrt(fits.covar[1,1]), loc = loc, nbins = 100)
  plot, loc, 1D * h / (loc[1] - loc[0]) / total(h), psym = 10
  oplot, loc, 1 / sqrt(2 * !pi) * exp(-loc^2 / 2), color = fsc_color('green')
end
