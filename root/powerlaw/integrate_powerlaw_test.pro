pro integrate_powerlaw_test

  data = powerlaw_fakegen(alpha = 2.3, xmin = 1, ntrial = 500)
  lmax = powerlaw_likelihood(data = data, alpha = 2.3, xmin = 1.22)
  t0 = systime(/seconds)
  print, integrate_powerlaw(data = data, $
                            alpha_limits = [2.0, 2.6], $
                            xmin_limits = [.8, 1.2], $
                            lmax = lmax)
  print, systime(/seconds) - t0
end
