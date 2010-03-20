;+
; PURPOSE:
;  This computes the cumulative distribution of the noncentral
;  chi-square distribution: P(chisq[f, theta] < x)
;
; CATEGORY:
;  Statistics
;
; INPUTS:
;  x: The number at which to evaluate the cdf. A scalar
;  f: The number of degrees of freedom. A non-negative scalar.
;  lambda: The non-centrality parameter
;  status: Set to a named variable to hold the status of the
;  calculation. A vector of length equal to x. A value of zero
;  indicates no problems. A value of 1 indicates a floating point
;  exception. A value of 2 indicates the sum did not converge after
;  1000 terms.
;
; OUTPUTS:
;  P(chisq[f,lambda] < x)
;
; PROCEDURE:
;  The CDF is computed as a poisson-weighted sum of central chi-2
;  distributions. The weighted sum starts at the location of the
;  greatest weight, and works forwards and backwards from there. The
;  function is prone to numerical error for extreme input values. It
;  seems that, the region of greatest instability is at
;  large values of x and lambda. 
;
;  I wrote this specifically to handle the case of nu = 2. For that,
;  it seems very well behaved for lambdas up to 100. By lambda = 200,
;  large values of x tend to skew above the distribution.
;
; RESTRICTIONS:
;  Beware of numerical instabilities at high values of lambda and/or x
;
; MODIFICATION HISTORY:
;  Feb 2010: Written by Chris Beaumont.
;-
function c2noncen_cdf, x, f, lambda, status

  compile_opt idl2

  ;- check inputs
  if n_params() lt 3 then begin
     print, 'calling sequence:'
     print, 'c2noncen_cdf(x, f, lambda, [status])'
     return, !values.f_nan
  endif
  
  sz = n_elements(x)
  sf = n_elements(f)
  sl = n_elements(lambda)
  err_msg = 'x, f, and lambda must have the same number of elements'
  if sf ne 1 && sf ne sz then message, err_msg
  if sl ne 1 && sl ne sz then message, err_msg

  if min(x) lt 0 then message, 'x must be positive'
  if min(lambda) lt 0 then message, 'lambda must be non-negative'
  if min(f) lt 0 then message, 'f must be non-negative'

    
  ;- max of the poisson weights is lambda / 2
  jstart = floor(lambda / 2)
  itmin = 20
  itmax = 500
  eps = 1d-8
  ;- the first term
  result = poisson_pdf(jstart, lambda/2D) * chisqr_pdf(x, f + 2 * jstart)
  status = result * 0
  ;- recurse
  result = c2noncen_recurse(result, jstart, 1, x, lambda, f, status)
                                
  ;- handle the special case of lambda = 0 separately
  central = where(lambda eq 0, lct)
  if lct ne 0 then result[central] = chisqr_pdf(x, f)

  return, result

  for i = 1, itmax, 1 do begin
     add1 = poisson_pdf(jstart - i, lambda / 2D) * $
            chisqr_pdf(x, f + 2 * (jstart - i))
     add2 = poisson_pdf(jstart + i, lambda / 2D) * $
            chisqr_pdf(x, f + 2 * (jstart + i))
     if (max(add1 + add2) le eps) and i gt itmin then break
     result += (add1 + add2)
  endfor
  if (i ge itmax) then status = 1
  return, result
end

pro test
  lambdas = [1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25]
  nus = [0,0,0,0,2,2,2,2,4,4,4,4,7,7,7,7]
  vals = [5.233, 11.914, 30.675, 43.002, $
          8.642, 14.641, 33.054, 45.308, $
          11.707, 17.309, 35.427, 47.613, $
          16.003, 21.228, 38.970, 51.061]
  ;- test 1. Can it do a single calculation correctly?
;  for i = 0, 15, 1 do print, c2noncen_cdf(vals[i], nus[i], lambdas[i])
  ;- test 2. Run them all at once
;  print, c2noncen_cdf(vals, nus, lambdas)

  ;- test 3. Test for stability with nu = 2
  ;- test 3a. Very small values of lambda
  x1 = randomn(seed, 5000) + 1d-3
  x2 = randomn(seed, 5000) + 1d-3
  chi2 = x1^2 + x2^2
  lambdas = 2 * 1d-6
  !p.multi = [0,1,2]
  
  edf, chi2, x, y, /plot
  x2 = arrgen(min(chi2), max(chi2), nstep = 100)
  y2 = c2noncen_cdf(x2, 2, lambdas,s)
  oplot, x2, y2, color = fsc_color('red')
  plot, x, (y - interpol(y2, x2, x)) / (y * (1 - y))
  !p.multi = 0
;  return

  ;- test3b: Large values of lambda
  lambda = 3d4
  x1 = randomn(seed, 1000) + sqrt(lambda / 2)
  x2 = randomn(seed, 1000) + sqrt(lambda / 2)
  chi2 = x1^2 + x2^2
  !p.multi = [0,1,2]
  
  edf, chi2, x, y, /plot
  x2 = arrgen(min(chi2), max(chi2), nstep = 100)
  y2 = c2noncen_cdf(x2, 2, lambda, s)
  oplot, x2, y2, color = fsc_color('red')
  plot, x, (y - interpol(y2, x2, x)) / (y * (1 - y)), psym = -4
  !p.multi = 0

  ;- edge case: central chi 2
  print, chisqr_pdf(5, 5), c2noncen_cdf(5, 5, 0D)

  
end
