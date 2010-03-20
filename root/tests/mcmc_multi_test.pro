;+
; PURPOSE:
;  This program defines and runs a simple test mcmc subclass. The
;  target distribution is a Gaussian.
;-

function mcmc_multi_test::selectTrial, current, transitionRatio = transitionRatio
  common mcmc_multi_test_seed, seed
  sigma = 2D
  transitionRatio = replicate(1, self.nchain)
  return, current + randomn(seed, self.nchain) * sigma
end

function mcmc_multi_test::logTargetDistribution, link
  mu = 5D
  sigma = 1D
  return, -(link - mu)^2 / (2 * sigma^2)
end

pro mcmc_multi_test__define
  data = {mcmc_multi_test, inherits mcmc_multi}
end


pro mcmc_multi_test

  nchain = 10
  seed = randomn(seed, nchain) + 2
  data = fltarr(nchain)

  mcmc = obj_new('mcmc_multi_test', seed, 100000, data, thin = 1)

  t = systime(/seconds)
  mcmc->run
  print, systime(/seconds) - t, format='("Run time: ", f0.2, " seconds ")'

  good = mcmc->getnsuccess(nfail = bad)

;  print, 1D * good / bad
  ;print, bad

  chain = mcmc->getChain()
  nstep = n_elements(chain[0,*])
  nchain = n_elements(chain[*,0])
  chain = chain[*, 0.1 * nstep: *]

  
  device, decomposed = 0
  loadct, 0
  plot, [0],[1], /nodata, xra = [2, 8], yra = [0, .5]
  loadct, 35
  loc = findgen(50) / 5
  for i = 0, nchain - 1, 1 do begin
;     h = histogram(chain[i,*], loc = loc, nbin = 50)
;     oplot, loc, 1D * h / (total(h) * (loc[1] - loc[0])), $
;            psym = 10, color = i * 255 / nchain
     mu = mean(chain[i,*])
     sig = stdev(chain[i,*])
     oplot, loc, 1 / sqrt(2 * !pi * sig^2) * $
            exp(-(loc - mu)^2 / (2 * sig^2)), $
            color = i * 255 / nchain
  endfor

  obj_destroy, mcmc
  return
end
