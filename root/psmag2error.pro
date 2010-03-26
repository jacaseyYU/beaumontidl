function psmag2error, mag, band, snr = snr
  p = psproperties()
  
  ;- convert the magnitudes to DN counts 
  src = p.f0[band] * 10^(-mag/2.5) * p.area * p.time[band]
  ;- get the sky counts per pixel
  bg = p.sky[band] * p.time[band] * p.area * p.pix_size^2
  ;- get the read noise
  rn = p.read_noise
  ;- get the effective background area in pixels
  beta = p.beta / p.pix_size^2
  b4pi = beta / (4 * !dpi) ;-  = psf variance, in pixels
  sigma = sqrt(p.beta / (4 * !dpi)) ;- psf sigma

  v_rms = rn^2 + bg

  snr = src / sqrt(src + beta * (bg + rn^2))

;  result = sqrt((b4pi / src) * (1 + b4pi * 8*!pi/src * (bg + rn^2)))
;  result = sqrt(result^2 + p.ast_floor^2)

  ;- lets do this myself
  signal = src
  noise = sqrt(src + beta * (bg + rn^2))
  snr = signal / noise
  result = sigma / snr
  result = sqrt(result^2 + p.ast_floor^2)

  return, result
end


pro test
  mags = arrgen(10D, 30D, .1D)
  plot, mags, mags, /nodata, yra = [0,2], /ylog
  for i = 0, 4, 1 do begin
     e = psmag2error(mags, i, snr = snr)
     j = psmag2snr(mags, mags * 0 + i, ast = ast)
     print, minmax(ast / e)
     oplot, mags, e
     oplot, mags, ast, /line
;     print, interpol(mags, snr, [100, 5])
  endfor
end
  
