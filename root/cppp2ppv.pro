function cppp2ppv, ppp, vel, bincenters
  
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
  
  if size(ppp, /type) ne 4 then ppp = float(ppp)
  if size(vel, /type) ne 4 then vel = float(vel)
  if size(bincenters, /type) ne 4 then bincenters = float(bincenters)
  
  result = fltarr(sz[0], sz[1], nbin)
  junk = call_external(lib[0], 'ppp2ppv', $
                       ppp, vel, bincenters, $
                       sz, nbin, result, /unload)
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
