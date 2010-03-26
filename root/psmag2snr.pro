function psmag2snr, mag, band, ast_err = ast_err

  fwhm = .8                                 ;- seeing in arcseconds
  sky = [6.9, 22.5, 48.7, 77.6, 89.6]       ;- sky background in DN s^-1 m^-2 "^-2
  f0 = [4.73, 5.87, 5.55, 3.78, 1.85] * 1d9 ;- 0 mag flux in DN s^-1 m^-2
  snr_max = 100                             ;- photometric error floor
  area = 1.73                               ;- collecting area in m^2
  time = [60D, 38, 30, 30, 30]              ;- exposure time per band in s
  read_noise = 5.                           ;- electrons / pixel                                             
  pix_size = .26                            ;- arcsec / pixel                                                
  sky_area = !pi * fwhm^2 / 4.              ;- aperture area in arcsec^2                                     
  pix_area = sky_area / pix_size^2          ;- aperture area in pixels                                       
  frac_flux = .5                            ;- amount of light gathered in 1 fwhm aperture
  ast_floor = .01                           ;- astrometric error floor, in arcsec


;  print, f0 * area / 1d9 * frac_flux, format='(5(f0.2, 2x))'
;  print, sky * area *  sky_area, format='(5(f0.2, 2x))'


  sky_flux = sky[band] * sky_area * area * time[band]
  source_flux = 10^(-mag/2.5) * f0[band] * area * time[band] * frac_flux
  noise = sqrt(source_flux + sky_flux + read_noise^2 * pix_area)
  snr = (source_flux / noise)
  result = snr < snr_max
  ast_err = fwhm / (2 * sqrt(2 * alog(2))) / snr
  ast_err = sqrt(ast_floor^2 + ast_err^2)
  return, result
end
