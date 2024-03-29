;+ run fit_pmpar many times, empirically find distribution of parallax
;and pm. compare to estimated uncertainties
;
; RESULTS
;  parallax error scales with (1D) position error as
;   dpi = 1.33 dpos * sqrt(1 / nobs)
;   dpm = 3.5  dpos * sqrt(1 / nobs) * 1/tbase (yrs)
;   dpi depends on dec. 
pro mc_par

  nobs = 100
  ra = randomu(seed) * 360
  dec = randomu(seed) * 180 - 90
;  ra = ten(2, 52, 56.8) * 15
;  dec = ten(0, -24, 17.9)
  tbase = 365.25 * 3.5
  niter = 60

  j2000 = 2451545.0D
  delta = replicate(1, nobs) * (tbase / nobs)
;  delta = 2 * randomu(seed, nobs) * (tbase /nobs)
  jd = j2000 + total(delta, /cumul)
  baseline = range(jd) / 365.25
  
  par_factor, ra, dec, jd, pr, pd
  
  noise = arrgen(1D, 30, nstep = niter) / 36d5

  fits = replicate({parfit}, niter)
  dpi = replicate(0., niter)
  dmu = replicate(0., niter)
  for i = 0L, niter - 1, 1 do begin
     noisevec = replicate(noise[i], nobs)

     ravec = ra + randomn(seed, nobs) * noise[i]   ; + pr / 36d5 * 10
     decvec = dec + randomn(seed, nobs) * noise[i]; - pd / 36d5 * 100
     fits[i] = fit_pmpar(jd, ravec, decvec, noisevec, noisevec)
     dpi[i] = sqrt(fits[i].covar[4,4])
     mu = sqrt(fits[i].ura^2 + fits[i].udec^2)
     dmx = fits[i].covar[1,1] & dmy = fits[i].covar[3,3]
     dmu[i] = sqrt(dmy)
  endfor
  plot, noise * 36d5, dpi, xtit='Positional error (mas)', $
        ytit = 'Parallax /pm error (mas)', psym = 4
  oplot, noise * 36d5, dmu, color = fsc_color('red'), psym = 4
;  oplot, minmax(noise/noise[0]), minmax(noise/noise[0]), color = fsc_color('red')
  a = linfit(noise * 36d5, dpi) & print, a 
  b = linfit(noise * 36d5, dmu) & print, b * [1, tbase/365.25]
  noise *= 36d5
  tbase /= 365.25
  oplot, noise, noise / sqrt(niter) * sqrt(5), /line
  oplot, noise, noise / sqrt(niter) * sqrt(5) / tbase, /line, color = fsc_color('red')
  oplot, noise, a[0] + a[1] * noise
  oplot, noise, b[0] + b[1] * noise, color = fsc_color('red')
  xyouts, .1, .8, 'New = solid. Old = dotted. Red = proper motion',/norm
  return

end

;- verify that proper motion errors are accurate
pro mc_par_2

  nobs = 100
  ra = randomu(seed) * 360
  dec = randomu(seed) * 180 - 90
;  ra = ten(2, 52, 56.8) * 15
;  dec = ten(0, -24, 17.9)
  tbase = 365.25 * 3.5
  niter = 10000

  j2000 = 2451545.0D
  delta = replicate(1, nobs) * (tbase / nobs)
  jd = j2000 + total(delta, /cumul)
  baseline = range(jd) / 365.25
  
  par_factor, ra, dec, jd, pr, pd

  noise = 1D / 36d5

  fits = replicate({parfit}, niter)
  noisevec = replicate(noise, nobs)

  dpi = replicate(0., niter)
  dmu = replicate(0., niter)
  for i = 0L, niter - 1, 1 do begin
     ravec = ra + randomn(seed, nobs) * noise   ; + pr / 36d5 * 10
     decvec = dec + randomn(seed, nobs) * noise; - pd / 36d5 * 100
     fits[i] = fit_pmpar(jd, ravec, decvec, noisevec, noisevec)
     dpi[i] = sqrt(fits[i].covar[4,4])
     mu = sqrt(fits[i].ura^2 + fits[i].udec^2)
     dmx = fits[i].covar[1,1] & dmy = fits[i].covar[3,3]
     dmu[i] = sqrt(dmy)
  endfor

  h = histogram(fits.udec, loc = l, nbins = 30)
  plot, l+(l[1]-l[0])/2, h / (total(h) * (l[1] - l[0])), psym = 10
  oplot, l, 1 / sqrt(2 * !pi * fits[0].covar[3,3]) * exp(-l^2 / (2 * fits[0].covar[3,3])), $
         color = fsc_color('green')
end
