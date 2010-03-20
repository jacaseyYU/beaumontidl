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
;  theta: The non-centrality parameter
;
; OUTPUTS:
;  P(chisq[f,theta] < x)
;
; PROCEDURE:
;  The algorithm is lifted from The Journal of the Royal Statistical
;  Society. Series C (Applied Statistics), Vol 41, no 2 (1992) pp
;  478-482. It is Algorithm AS 275, by Chern G. Ding.
;
; RESTRICTIONS:
;  This function is not well behaved for x or theta >~ 80
;
; MODIFICATION HISTORY:
;  Feb 2010: Written (well, stolen) by Chris Beaumont.
;-
function c2noncen_cdf, x, f, theta, status, eps = eps

  compile_opt idl2

  ;- check inputs
  if n_params() lt 3 then begin
     print, 'calling sequence:'
     print, 'c2noncen_cdf(x, f, theta, [status, eps = eps])'
     return, !values.f_nan
  endif
  
  sz = n_elements(x)
  sf = n_elements(f)
  sl = n_elements(theta)
  err_msg = 'x, f, and theta must have the same number of elements'
  if sf ne 1 && sf ne sz then message, err_msg
  if sl ne 1 && sl ne sz then message, err_msg

  if min(x) le 0 then message, 'x must be positive'
  if min(theta) lt 0 then message, 'theta must be non-negative'
  if min(f) lt 0 then message, 'f must be non-negative'
 
  errmax = 1d-6
  itrmax = 50

  chi2nc = x
  lam = double(theta / 2D)
  
  ;- evaluate the first term

  n = 1D
  u = exp(-lam)
  v = u
  x2 = x / 2D
  f2 = f / 2D

  t = x2 ^ f2 * exp(-x2) / exp(lngamma(f2+1D))
  term = v * t
  chi2nc = term
  
  ;- check if f + 2n is greater than x
  flag = 0
  pos10:
  if ( (f + 2D * n - x) le 0) then goto, pos30
  
  ;- find error bound and check for convergence
  flag = 1
  pos20:
  bound = t * x / (f + 2D * n - x)
  if (bound gt errmax and fix(n) le itrmax) then goto, pos30
  if (bound gt errmax) then ifault = 1
  return, chi2nc

  ;- evaluate the next term of the expansion and then the partial sum
  pos30:
  u = u * lam / n
  v = v + u
  t = t * x / (f + 2D * n)
  term = v * t
  chi2nc += term

  n++
  if (flag) then goto, pos20
  goto, pos10

end

pro test
  lambdas = [1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25]
  nus = [0,0,0,0,2,2,2,2,4,4,4,4,7,7,7,7]
  vals = [5.233, 11.914, 30.675, 43.002, $
          8.642, 14.641, 33.054, 45.308, $
          11.707, 17.309, 35.427, 47.613, $
          16.003, 21.228, 38.970, 51.061]
  ;- test 1. Can it do a single calculation correctly?
  ;- result should be ~.95
  l = lambdas[0]
  n = nus[0]
  print, c2noncen_cdf(5.233, n, l, eps = 1d-3)

  for i = 0, 15, 1 do print, c2noncen_cdf(vals[i], nus[i], lambdas[i])
;  return
  
  ;- test 2. Test for arrays
  ;- results should be .95. Looks pretty good except for nu=7
;  print, c2noncen_cdf(vals, nus, lambdas, eps = 1d-3)

  ;- test 3. Test for stability
  for lambda = 0, 50, 5 do begin
     for nu = 0, 10, 3 do begin
        x = arrgen(0.1, 200, 1)
        y = x
        for i = 0, n_elements(x) - 1, 1 do y[i] = c2noncen_cdf(x[i], nu, lambda)
        plot, x, y, title=string(lambda, nu, format='("lambda : ", i2, " nu: ", i2)')
        wait, 1
     endfor
  endfor

  return
  mu1 = randomn(seed) * 30
  mu2 = randomn(seed) * 30
  sig1 = 1D & sig2 = 1D

  num = 1000
  r1 = randomn(seed, num) * sig1 + mu1
  r2 = randomn(seed, num) * sig2 + mu2
  chi = (r1/sig1)^2 + (r2/sig2)^2
  lambda = (mu1 / sig1)^2 + (mu2 / sig2)^2

  edf, chi, x, y, /plot
  y = chi * 0
  for i = 0, num-1, 1 do y[i] = c2noncen_cdf(x[i], 2, lambda)
  oplot, x, y, color = fsc_color('red')
end
