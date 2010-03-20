pro integrate_lognormal_test

  data = lognormal_dist(500, mu = 3, sigma = .5, xmin = 0, $
                       seed = 5)
  lmax = lognormal_mle([3,.5], data = data, xmin = 0)
  lmax /= -2
  t0 = systime(/seconds)
  print, integrate_lognormal(data = data, $
                             mu_limits = [2.7, 3.3], $
                             sigma_limits = [.3, .7], $
                             lmax = lmax, $
                             xmin = 0)
  print, systime(/seconds) - t0
end
