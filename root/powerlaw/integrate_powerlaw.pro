
;- calculate likelihood(x) / Lmax (both linear)
function pl_scaled_likelihood, data = data, alpha = alpha, xmin = xmin, lmax = lmax
  return, exp(powerlaw_likelihood(data = data, alpha = alpha, xmin = xmin) - lmax)
end


;- calculate likelihood at fixed alpha
function pl_fixalpha, xmin
  common int_pl_common, alpha, junkx, data, lmax, alpha_limits
  return, pl_scaled_likelihood(data = data, alpha = alpha, $
                            xmin = xmin, lmax = lmax)
end

;- calculate likelihood at fixed xmin
function pl_fixxmin, alpha
  common int_pl_common, junka, xmin, data, lmax, alpha_limits
  return, pl_scaled_likelihood(data = data, alpha = alpha , $
                            xmin = xmin, lmax = lmax)
end

;- 1D likelihood integral over alpha
function integrate_pl_1dalpha, xmin
  common int_pl_common, alpha, junkx, data, lmax, alpha_limits
  junkx = xmin
  safedata = data
  subdat = where(data ge xmin, ct)
  if ct eq 0 then return, 0
  data = data[subdat]
  result =  qsimp('pl_fixxmin', alpha_limits[0], alpha_limits[1], /double, eps = 1d-6)
  data = safedata
  print, xmin, result, format='("1d integration. xmin:", e11.3, " integral: ", e11.3)'
  wait, .1
  return, result
end

;- 2d integral
function integrate_powerlaw, data = data, alpha_limits = alpha_limits, $
                       xmin_limits = xmin_limits, $
                       lmax = lmax
  common int_pl_common, thealpha, thexmin, thedata, thelmax, thealphalim
  thealpha = alpha_limits[0]
  thexmin = xmin_limits[0]
  thedata = data
  thelmax = lmax
  thealphalim = alpha_limits
  !except = 0
  result, qsimp('integrate_pl_1dalpha', xmin_limits[0], xmin_limits[1], $
                /double, eps = 1d-6)
  !except = 1
  return, result
end
