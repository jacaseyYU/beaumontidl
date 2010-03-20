;+
; PURPOSE:
;  This function returns the improper integral of the product of two
;  Cauchy distributions, evaluated at a given point. 
;
; CALLING SEQUENCE:
;  result = cauchy_double_integral(x, gamma, lambda, mu, nu)
;
; INPUTS:
;  x: The value at which to evaluate the double cauchy function
;  gamma: The width of the first Cauchy
;  lambda: The width of the second Cauchy
;  mu: The center of the first Cauchy
;  nu: The center of the second Cauchy
;
; OUTPUTS:
;  Integral(Cauchy(x ; mu, gamma) * Cauchy(x ; nu, lambda) dx) + const
;
; PROCEDURE:
;  The formula is copied over from Wolfram alpha. Unfortunately, there
;  are situations in which this formulation is indeterminate (e.g,
;  when gamma = lambda and mu = nu).
;
; MODIFICATION HISTORY:
;  October 2009: Written by Chris Beaumont
;-
function cauchy_double_integral, x, gamma, lambda, mu, nu
  compile_opt idl2
  on_error, 2

  ;- check inputs
  if n_params() ne 5 then begin
     print, 'cauchy_double_integral calling sequence:'
     print, 'result = cauchy_double_integral(x, gamma, lambda, mu, nu)'
     return, !values.f_nan
  endif
  if gamma le 0 || lambda le 0 then $
     message, 'Gamma and lambda must both be positive'
  
  ;- this ugliness is from wolfram alpha
  ;- XXX situations where num / denom = 0 / 0
  numer = gamma * $
          (atan((x-nu)/lambda) * (gamma^2-lambda^2+(mu-nu)^2)-lambda * (mu-nu) * $
           (alog(x^2 - 2 * x * mu + gamma^2 + mu^2)-alog(x^2-2 * x * nu + lambda^2 + nu^2))) $
          + lambda * atan((x-mu)/gamma) * (-gamma^2 + lambda^2 + (mu-nu)^2)
  denom = (!dpi^2 * (gamma^4 - 2 * gamma^2 * (lambda^2 - (mu - nu)^2) + (lambda^2 + (mu-nu)^2)^2))
  
  result = numer / denom

  return, result
  
end
