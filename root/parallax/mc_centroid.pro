function model, x, params
  common mc_centroid, sky, fwhm, naxis1, naxis2, seed
  sig = fwhm / (2 * sqrt(2 * alog(2)))
  psf = alog(1 / (2 * !pi * sig^2)) - $
        ((x[0,*] - params[1])^2 + (x[1,*] - params[2])^2) / (2 * sig^2)
  good = where(psf gt -40, goodct)
  result = psf * 0 + sky[0]
  if goodct ne 0 then result[good] += exp(double(psf[good])) * params[0]
  
  return, result
end

pro mc_centroid
  common mc_centroid, sky, fwhm, naxis1, naxis2, seed
  fwhm = .8                     ;-arcsec
  pixel = 0.26                  ;- arcsec/pixel
  sz = fwhm * 5
  area = 1.73                   ;-m^2
  texp = [60, 38, 30, 30, 30]
  sky = [6.9,22.5,48.7,77.6,89.6] ;-s^-1 m^-2 "^-2
  sky *= texp *area * pixel^2     ;-sky counts per pixel
  fzero=[4.73, 5.87, 5.55, 3.78, 1.85] * 1d9 * area * texp
  read = 5                        ;- per pixel, sigma
  
  naxis1 = 40 & naxis2 = 40
  x = reform(rebin(indgen(naxis1),naxis1, naxis2), naxis1 * naxis2)
  y = reform(rebin(1#indgen(naxis2),naxis1, naxis2), naxis1 * naxis2)
  x = transpose([[x],[y]])
  
  niter = 100
  !except = 0
  mags = arrgen(10D, 30D, 1D)
  dx = mags * 0 & dy = mags * 0
  flux = fzero[0] * 10^(-mags / 2.5)
  for k = 0, n_elements(mags) - 1, 1 do begin
     for j = 0, niter - 1, 1 do begin
        pos = randomu(seed, 2)*[naxis1,naxis2]/4 + [naxis1,naxis2]/2
        signal = dblarr(naxis1, naxis2)
        star = model(x, [flux[k], pos[0], pos[1]])
        
        np = n_elements(star)
        for i = 0, np-1, 1 do $
           star[i] = randomu(seed,1, poisson=star[i]+sky[0],/double) + $
           randomn(seed,1)*read
        y = star
        junk = mpfitfun('model', x, y, sqrt(star + sky[0] + read^2), $
                        [1d9, pos[0],pos[1]], /quiet, status = s)
        xmean = total(x[0,*] * total(y,1)) / total(total(y,1))
        ymean = total(x[1,*] * total(y,2)) / total(total(y,2))
        ;dx[k] += (xmean - pos[0])^2
        ;dy[k] += (ymean - pos[1])^2
        dx[k] += (junk[1] - pos[0])^2
        dy[k] += (junk[2] - pos[1])^2
;        print, junk[1] - pos[0], s
     endfor
     dx[k] = sqrt(dx[k] / niter)
     dy[k] = sqrt(dy[k] / niter)
  endfor
  plot, flux, dx, /xlog, /ylog, psym = -4
  oplot, flux, dy, color = fsc_color('red'), psym = -4

  a = linfit(alog(flux), alog(dx))
  print, a
  oplot, flux, exp(a[0]) * flux^a[1], color = fsc_color('blue')
  !except = 1
end
