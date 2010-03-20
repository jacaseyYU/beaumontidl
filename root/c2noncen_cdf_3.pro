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

  a = double(sqrt(theta))
  b = sqrt(double(x))
  m = double(f)
  print, m, a, b
  meven = (m mod 2) eq 0
  a2mb = (a^2 + m) lt b^2
  eps = 1d-16

  ;-initializations
  if meven then begin
     if a2mb then begin
        r = a / b
        f1 = 1D
     endif else begin
        r = b / a
        f1 = 0D
     endelse

     t1 = 1D
     f2 = 0D
     q = 2D
     v = 1D
     s = exp(-(a - b)^2 / 2D)
  endif else begin ;- m is odd
     if a2mb then begin
        r = a / b
        f1 = 1 / sqrt(r)
     endif else begin
        r = b / a
        f1 = (fix(m) eq 1) ? sqrt(r) : 0D
     endelse
     t1 = sqrt(r)
     f2 = 0D
     q = 0D
     v =1.5D
     s = (2 * !dpi * a * b)^(-0.5D) * (1 - exp(-2 * a * b)) * $
         exp(-(a - b)^2D/2)
  endelse
  g1 = 1D
  g2 = 0D
  DenTest = (3 / eps) * (1 + (!dpi * a * b / 2)^(0.5D))
  NumTest1 = r * DenTest
  NumTest2 = (6 / eps) * (b / a)^(m / 2D - 1D)
  
  itrmax = 5000
  help, a, b, r, f1, f2, t1, q, v, s, g1, g2, dentest, numtest1, numtest2
  for jj = 1, itrmax - 1, 1 do begin
     t = r * t1
     
     if meven and a2mb then p = (v lt m/2) ? t + 1 / t : t
     if meven and ~a2mb then p = (v lt m/2) ? 0D : t
     if ~meven and a2mb then p = (v lt m/2) ? 1/t : 0D
     if ~meven and ~a2mb then p = (v lt m/2) ? 0D : t
     f = p + 2 * v / (a * b) * f1 + f2
     g = q + 2 * v / (a * b) * g1 + g2

     max = 1d1
     div = 1d10
     if 0 && ((f gt max) || (g gt max)) then begin
        f /= div & g/= div
        f1 /= div & g1 /= div
        f2 /= div & g2 /= div
        t /= div & t1 /= div
        numTest1 /= div & numtest2 /= div
        denTest /= div
     endif

     print, s * f / g
     done =  ((v ge m/2) and (f gt t * numTest1) and $
              (f gt NumTest2) and (g gt DenTest))
     if done then break
     v = v + 1
     f2 = f1 & f1 = f
     g2 = g1 & g1 = f
     t1 = t
  endfor
  if jj ge itrmax then print, 'failed to converge' else print, jj
  if meven and a2mb then q = s * f / g
  if meven and ~a2mb then p= s * f / g
  if ~meven and a2mb then q=(1 - gauss_pdf(b+a)) + (1-gauss_pdf(b-a)) + s * f / g
  if ~meven and ~a2mb then p = s * f / g
  help, f eq g
  if a2mb then p = 1 - q
  return, p

end

pro test
;  print, c2noncen_cdf(1, 3, .25)
  print, c2noncen_cdf(100, 2, 100)
;  print, c2noncen_cdf(1D4, 2, 1D4)
  return


  lambdas = [1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25, 1, 4, 16, 25]
  nus = [0,0,0,0,2,2,2,2,4,4,4,4,7,7,7,7]
  vals = [5.233, 11.914, 30.675, 43.002, $
          8.642, 14.641, 33.054, 45.308, $
          11.707, 17.309, 35.427, 47.613, $
          16.003, 21.228, 38.970, 51.061]
  ;- test 1. Can it do a single calculation correctly?
  for i = 0, 15, 1 do print, c2noncen_cdf(vals[i], nus[i], lambdas[i])
  return
  
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
