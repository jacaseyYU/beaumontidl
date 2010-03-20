;+
; PURPOSE:
;  These procedures calculate the integral of the log-normal
;  likelihood function. That is, it calculates
;    Integral( dSigma dMu L(data; xmin, sigma, mu)
;
; CALLING SEQUENCE:
;  result = integrate_lognormal( data = data, mu_limits = mu_limits, 
;                                sigma_limits = sigma_limits, lmax =
;                                lmax, xmin = xmin)
;
; INPUTS:
;  data: A vector of data, which must satisfy min(data) >= xmin
;  mu_limits: A two element vector giving the lower and upper bounds
;             of the mu integration
;  sigma_limits: A two element vector giving the lower and upper
;                bounds of the sigma integration
;  lmax: A value for the log-likelihood of the data (near) the maximum
;        likelihood value. This is needed to normalize the integrand
;        which can be too small to compute (instead, the program works
;        with log-likelihoods)
;  xmin: The value for xmin.
;
; OUTPUTS:
;  Integral(dMu dSigma P(data; mu, sigma, xmin)) / exp(lmax)
;-

;-
; returns Likelihood(x) / Lmax (linear units)
; lmax: log of the maximum likelihood
;-
function scaled_likelihood, mu = mu, data = data, sigma = sigma, lmax = lmax, xmin = xmin
  return, exp(lognormal_mle([mu,sigma], data = data, xmin = xmin)/(-2D) - lmax)
end

;- calculate likelihood at a fixed mu
function lognormal_fixmu, sigma
  common int_ln_common, mu, junksigma, data, lmax, mu_limits, xmin
  return, scaled_likelihood(mu = mu, sigma = sigma, data = data, lmax = lmax, xmin = xmin)
end

;- calculate likelihood at a fixed sigma
function lognormal_fixsigma, mu
  common int_ln_common, junkmu, sigma, data, lmax, mu_limits, xmin
  return, scaled_likelihood(mu = mu, sigma = sigma, data = data, lmax = lmax, xmin = xmin)
end

;- perform a 1D likelihood integral over mu
function integrate_lognormal_1dmu, sigma
  common int_ln_common, mu, junksigma, data, lmax, mu_limits, xmin
  junksigma = sigma
  return, qsimp('lognormal_fixsigma', mu_limits[0], mu_limits[1], /double, eps = 1d-6)
end

;- perform a 2D likelihood integral over mu, sigma
function integrate_lognormal, data = data, mu_limits = mu_limits, $
                              sigma_limits = sigma_limits, $
                              lmax = lmax, $
                              xmin = xmin
  common int_ln_common, themu, thesigma, thedata, thelmax, themulimits, thexmin
  themu = mu_limits[0] ;- not needed
  thesigma = sigma_limits[0] ;- not needed
  thedata = data
  thelmax = lmax
  themulimits = mu_limits
  thexmin = xmin
  !except = 0
  result = qsimp('integrate_lognormal_1dmu', sigma_limits[0], sigma_limits[1], /double, eps = 1d-6)
  !except = 1
  return, result
end
  
  
