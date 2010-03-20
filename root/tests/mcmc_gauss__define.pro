;+
; PURPOSE:
;  This program defines and runs a simple test mcmc subclass. The
;  target distribution is a Gaussian.
;-


function mcmc_test::selectTrial, current, transitionRatio = transitionRatio
  common mcmc_test_seed, seed
  transitionRatio = 1
  sigma = 2
  return, current + randomn(seed)
end

function mcmc_test::logTargetDistribution, link
  mu = 5
  sigma = 1
  return, -(link - mu)^2 / (2 * sigma^2)
end

pro mcmc_test__define
  data = {mcmc_test, inherits mcmc}
end


pro mcmc_test

  seed = 10D

  mcmc = obj_new('mcmc_test', seed, 100000, data, thin = 1)
  t = systime(/seconds)
  mcmc->run
  print, systime(/seconds) - t, format='("Run time: ", f0.2, " seconds ")'
  good = mcmc->getnsuccess(nfail = bad)

  print, good, bad
  chain = mcmc->getChain()


  nstep = n_elements(chain)
  chain = chain[0.1 * nstep: *]
;  plot, chain
  h = histogram(chain, loc = loc, nbin = 50)
  f = gaussfit(loc, h, a, nterm = 3)
  print, a
  print, mean(chain), stdev(chain)
  plot, loc, h, psym = 10
  oplot, loc, f, color = fsc_color('red')
  obj_destroy, mcmc
  return
end
