pro modelplot, x, data, model
  common mc_centroid, sky, fwhm, naxis1, naxis2, seed, index, pixel
  tvimage, bytscl(reform(data, naxis1 ,naxis2)), pos = [.05, .45, .45, .95]
  lo = min(data, max =hi)
  mim = model(x, model)
  im = 0 > ((mim - lo) / (hi - lo) * 255) < 255
  tvimage, reform(byte(im), naxis1, naxis2), $
           pos = [.5, .45, .95, .95]
  im = 0 > ((data - mim - lo) / (hi - lo) * 255) < 255
  tvimage, reform(byte(im), naxis1, naxis2), $
           pos = [.05, .05, .45, .45]
end

function model, x, params
  common mc_centroid, sky, fwhm, naxis1, naxis2, seed, index, pixel
  sig = fwhm / (2 * sqrt(2 * alog(2))) / pixel
  psf = alog(1 / (2 * !pi * sig^2)) - $
        ((x[0,*] - params[1])^2 + (x[1,*] - params[2])^2) / (2 * sig^2)
  good = where(psf gt -40, goodct)
  result = psf * 0 + sky[index]
  if goodct ne 0 then result[good] += exp(double(psf[good])) * params[0]
  
  return, result
end

pro mc_centroid
  common mc_centroid, sky, fwhm, naxis1, naxis2, seed, index, pixel
  doskip = 1
  if doskip then goto, skip
  fwhm = .8                     ;-arcsec
  factor = 10
  pixel = 0.26                  ;- arcsec/pixel
  sz = fwhm * 5
  area = 1.73                   ;-m^2
  texp = [60, 38, 30, 30, 30]
  sky = [6.9,22.5,48.7,77.6,89.6] ;-s^-1 m^-2 "^-2
  sky *= texp *area * pixel^2     ;-sky counts per pixel
  fzero=[4.73, 5.87, 5.55, 3.78, 1.85] * 1d9 * area * texp
  read = 5                        ;- per pixel, sigma
 
  naxis1 = ceil(5 * fwhm / pixel) & naxis2 = naxis1
  
  x = reform(rebin(indgen(naxis1),naxis1, naxis2), naxis1 * naxis2)
  y = reform(rebin(1#indgen(naxis2),naxis1, naxis2), naxis1 * naxis2)
  x = transpose([[x],[y]])
  
  niter = 100
  nseed = 30
  empirical = 1
  !except = 0
;  mags = arrgen(12D, 26D, 2D)
  mags = arrgen(12.8, 20., 2D)
  dx = mags * 0 & dy = mags * 0
  delta = fltarr(5, n_elements(mags))
  np = naxis1 * naxis2
  for k = 0, n_elements(mags) - 1, 1 do begin
     print, k, n_elements(mags) - 1
     for j = 0, niter - 1, 1 do begin
        pos = (randomu(seed, 2)-.5)*[naxis1,naxis2]/4 + [naxis1,naxis2]/2
        pos = [naxis1,naxis2]/2
        ;help, y
        for index = 0, 4, 1 do begin
           flux = fzero[index] * 10^(-mags[k]/2.5)
           star = model(x, [flux, pos[0], pos[1]])        
           for i = 0, np-1, 1 do $
              y[i] = randomu(seed,1, poisson=star[i]+sky[index],/double) + $
              randomn(seed,1)*read
           ybak = y
           ;print, junk, [flux, pos[0], pos[1]]
           ;if j eq 0 then begin
           ;   erase
           ;   modelplot, x, ybak, junk
           ;   stop
           ;endif
           best = 0
           bestval = !values.f_infinity
           ;- what error do we expect?
           err = psmag2snr(mags[k], index, ast = ast)
           err = ast / pixel
           sky_err = sqrt(star + sky[index] + read^2)
           nimprove = 0
           for ii = 0, nseed - 1, 1 do begin
              seedx = pos[0] + randomn(seed) * err
              seedy = pos[1] + randomn(seed) * err
              junk = mpfitfun('model', x, y[*], $
                              sky_err, $
                              [flux, seedx, seedy], $
                              /quiet, $
                              status = s, covar=c, yfit = yfit)
              chi2 = total((yfit - y)^2 / (sky_err^2),/nan)
              if chi2 lt bestval then begin
                 ;print, 'better!',abs(best - junk[1]) / err
                 bestval = chi2
                 best = junk[1]
                 nimprove = ii
              endif
           endfor
           print, nimprove
           if ~empirical then delta[index,k] += sqrt(c[1,1]) else $
              delta[index, k] += (best - pos[0])^2
           
        endfor
     endfor
  endfor 
  if ~empirical then begin
     dg = reform(delta[0, *]) * pixel / niter
     dr = reform(delta[1, *]) * pixel / niter
     di = reform(delta[2, *]) * pixel / niter
     dz = reform(delta[3, *]) * pixel / niter
     dy = reform(delta[4, *]) * pixel / niter
  endif else begin
     dg = sqrt(delta[0,*] / niter) * pixel
     dr = sqrt(delta[1,*] / niter) * pixel
     di = sqrt(delta[2,*] / niter) * pixel
     dz = sqrt(delta[3,*] / niter) * pixel
     dy = sqrt(delta[4,*] / niter) * pixel
     dg = reform(dg) & dr = reform(dr) & di = reform(di)
     dz = reform(dz) & dy = reform(dy)
  endelse

  skip:
  if doskip then restore, 'ps_centroid_err.sav'

  junk = psmag2snr(mags, mags * 0, ast = ast)
  plot, mags, dg, psym = -4, yra = minmax([ast, dg, dr, di, dz, dy]), /ylog
  oplot, mags, ast, /line
  oplot, mags, psmag2error(mags, mags * 0), line = 2

  oplot, mags, dr, psym = -4, color = fsc_color('red')
  junk = psmag2snr(mags, mags * 0+1, ast = ast)
  oplot, mags, ast, /line, color = fsc_color('red')

  oplot, mags, di, psym = -4, color = fsc_color('orange')
  junk = psmag2snr(mags, mags * 0+2, ast = ast)
  oplot, mags, ast, /line, color = fsc_color('orange')

  oplot, mags, dz, psym = -4, color = fsc_color('blue')
  junk = psmag2snr(mags, mags * 0+3, ast = ast)
  oplot, mags, ast, /line, color = fsc_color('blue')
  
  oplot, mags, dy, psym = -4, color = fsc_color('purple')
  junk = psmag2snr(mags, mags * 0+4, ast = ast)
  oplot, mags, ast, /line, color = fsc_color('purple')
  oplot, mags, psmag2error(mags, mags * 0+4), line = 3, color = fsc_color('purple')
;  save, mags, dg, dr, di, dz, dy, file='ps_centroid_err.sav'
  !except = 1

  fwhm = .8                     ;-arcsec
  factor = 10
  pixel = 0.26                  ;- arcsec/pixel
  sz = fwhm * 5
  area = 1.73                   ;-m^2
  texp = [60, 38, 30, 30, 30]
  sky = [6.9,22.5,48.7,77.6,89.6] ;-s^-1 m^-2 "^-2
  sky *= texp *area * pixel^2     ;-sky counts per pixel
  fzero=[4.73, 5.87, 5.55, 3.78, 1.85] * 1d9 * area * texp
  read = 5                        ;- per pixel, sigma

  sigma = fwhm / (2 * sqrt(2 * alog(2))) / pixel
  aeff = !pi * sigma^2            ;- effective sky pixels
  
  index = 4
  sig = fzero[index] * 10^(-mags / 2.5)
  skysig = aeff * sky[index]
  noise = sqrt(sig + skysig + aeff * read^2)
  snr = sig / noise
  a = linfit(1/snr, dg)
;  oplot, mags, a[0] + a[1] / snr
end
