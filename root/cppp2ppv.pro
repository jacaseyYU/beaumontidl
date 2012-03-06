function cppp2ppv, ppp, vel, bincenters, smear = smear, anti = anti

  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppp2ppv(ppp, vel, bincenters, [dimension = dimension, /mask])'
     return, !values.f_nan
  endif

  lib = file_which('ppp2ppv.so')
  if lib eq '' then $
     message, 'Cannot find ppp2ppv.so'

  sz = size(ppp)
  sz = long(sz[1:3])
  nbin = long(n_elements(bincenters))

  if keyword_set(anti) then begin
     sz *= anti
     nbin *= anti
     _ppp = congrid(ppp, sz[0], sz[1], sz[2], cubic=-0.5)
     _vel = congrid(vel, sz[0], sz[1], sz[2], cubic=-0.5)
     _bincenters = arrgen(bincenters[0], bincenters[n_elements(bincenters)-1], $
                          nstep = nbin)
  endif else begin
     _ppp = ppp
     _vel = vel
     _bincenters = bincenters
  endelse

  if size(_ppp, /type) ne 4 then _ppp = float(_ppp)
  if size(_vel, /type) ne 4 then _vel = float(_vel)
  if size(_bincenters, /type) ne 4 then _bincenters = float(_bincenters)

  result = fltarr(sz[0], sz[1], nbin)
  junk = call_external(lib[0], 'ppp2ppv', $
                       _ppp, _vel, _bincenters, $
                       sz, nbin, result)

  if keyword_set(anti) then begin
     sz /= anti
     nbin /= anti
     ;result = congrid(result, sz[0], sz[1], nbin, cubic=-0.5)
  endif

  if keyword_set(smear) then begin
     nonneg = min(result) ge 0
     dv = abs(bincenters[1] - bincenters[0])
     fwhm = smear / dv
     npix = ceil(3 * fwhm) / 2 * 2 + 1
     psf = psf_gaussian(npixel = npix, fwhm = fwhm)
     ;- only central column is nonzero
     s = size(psf)
     psf[0:s[1] / 2 - 1, *] = 0
     psf[s[1] / 2 + 1:*, *] = 0
     psf = psf[s[1]/2 - 1: s[1]/2 + 1, *]
     psf /= total(psf, /double)
     for i = 0, sz[0] - 1, 1 do begin
        plane = reform(result[i, *, *])
        plane = convolve(plane, psf, ft_psf = ft_psf)
        ;stop
        result[i, *, *] = plane
     endfor
     if nonneg then result >= 0
  endif
  return, result
end



pro test

  sz = 64
  ppp = mrdfits('~/stella_sims/pltvp3480_ppp.fits',0,h)
  ppp = float(ppp / max(ppp, /nan))
  vel = mrdfits('~/stella_sims/pltvp3480_zvel.fits',0,h)

  vcen = arrgen(-1d6, 1d6, nstep = 130)
  print, minmax(vel) / 1d5

  t0 = systime(/seconds)
  ppv1 = ppp2ppv(ppp, vel, vcen)
  writefits, '~/ppv.fits', ppv1
  t1 = systime(/seconds)
  print, time2string(t1 - t0)
  print, minmax(ppv1)

  t0 = systime(/seconds)
  ppv2 = cppp2ppv(ppp, vel, vcen)
  t1 = systime(/seconds)
  print, time2string(t1 - t0)
  print, minmax(ppv2)
  result = [ ppv1, ppv2]

  print, total(ppp), total(ppv1), total(ppv2)
  maxviz, result
end
