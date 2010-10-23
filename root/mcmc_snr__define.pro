function mcmc_snr::logTargetDistribution, link
  if link.ff lt 0 || link.ff gt 1 then return, -1e50

  ;- run the radiative transfer
  co12 = radex('co.dat', 345., 2., link.t, 10^(link.n), 3., 10^(link.nco), $
               self.width)
  co13 = radex('13co.dat', 330.58, 2., link.t, 10^(link.n), 3., 10^(link.nco)/70., $
               self.width)
;  hcn = radex('hcn@xpol.dat', 354.505, 2., link.t, 10^(link.n), 3., 10^(link.nhcn), $
;              self.width)
;  hcop = radex('13co.dat', 330.58, 2., link.t, 10^(link.n), 3., 10^(link.nhcop), $
;               self.width)
  f12 = 14.41 & d12 = .07
  f13 = 0.63 & d13 = .01
  r =  -(f12 - co12.tr * link.ff)^2 / (2 * d12^2) - $
       (f13 - co13.tr*link.ff)^2 / (2 * d13^2)
  print, co12.tr * link.ff, co13.tr * link.ff, r
  return, r
         
end

function mcmc_snr::selectTrial, current, transitionRatio = transitionRatio
  common mcmc_snr, seed
  transitionRatio = 1.
  result = current

  ;- option 1. small step in some direction
  if randomu(seed) gt .5 then begin
     
     dt = .6 & dn = .1 & dnco = .01 & dff = .005
     r = randomn(seed, 4) * [dt, dn, dnco, dff]
     a= floor(randomu(seed) * 4)
     val = r[a]
     r *= 0 & r[a] = val
     result.t += r[0]
     result.n += r[1]
     result.nco += r[2]
     result.ff += r[3]
  endif else begin
     print, 'big'
     ;- big step, where t * ff is constant
     dt = 2 & dn = .1 & dnco = .01
     r = randomn(seed, 3) * [dt, dn, dnco]
     result.t += r[0]
     result.n += r[1]
     result.nco += r[2]
     result.ff = current.ff * current.t/result.t
  endelse
  return, result
end


function mcmc_snr::init, seed, nstep, data, thin = thin, flux = flux, width = width, $
                         dflux = dflux
  compile_opt idl2

  junk = self->mcmc::init(seed, nstep, data, thin = thin)
  if junk ne 1 then return, junk

  if ~keyword_set(flux) || n_elements(flux) ne 4 then $
     message, 'must provide 4 fluxes in k km/s'
  self.flux = flux
  if ~keyword_set(width) then message, 'must provide width in km/s'
  self.width = width
  if n_elements(dflux) ne 4 then message, 'must provide 4 flux errors'
  self.dflux = dflux
  return, 1
end

pro snr_link__define
  data = {snr_link, $
          t: 0., n: 0., nco: 0., nhcop: 0., n13co:0., nhcn:0., ff:0.}
end

pro mcmc_snr__define
  data = {mcmc_snr, $
          inherits mcmc, $
          width: 0., $
          flux: fltarr(4), $
          dflux:fltarr(4) $
         }
end


pro test
  
  seed = {snr_link}
  seed = {snr_link, t:60., n:5., nco:17.8, nhcop:-8., n13co:-4., nhcn:-8., ff:.3}
  flux = [335.87, 11.65, 7.12, 4.32]
  dflux = [4.37, 0.333, 0.306, 0.219]
  mcmc = obj_new('mcmc_snr', seed, 1000, flux = flux, dflux = dflux, width = 9.)
  mcmc->run
  chain = mcmc->getChain()
  !p.multi = [0, 1, 4]
  !p.charsize = 2.5
  plot, chain.t, psym = 3
  plot, chain.n, psym = 3
  plot, chain.nco, psym = 3
  plot, chain.ff, psym = 3
  stop
end

  
