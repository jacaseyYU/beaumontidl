;+
; PURPOSE:
;  This function computes the maximum likelihood value of alpha for
;  discretely sampled data drawn from an exponential distribution:
;    P(x) = A exp(alpha * x), x < xmax
;  the normalization constant A is given by alpha exp(-alpha
;  xmax). The function maximizes the likelihood at a fixed value of
;  xmax.
;
; INPUTS:
;  x: The data
;  xmax: The upper bound to consider. Only values of x < xmax are
;        considered in the calculation.
;
; KEYWORD PARAMETERS:
;  xmin: An optional lower limit for the distribution.
;
; OUTPUTS:
;  The maximum likelihood value for alpha
;
; PROCEDURE:
;  We use the following closed-form equation for the max-likelihood
;  value of alpha:
;    alpha_max = [xmax - <x>]^-1
;  or, if xmin is provided
;    alpha_max = [xmax - xmin - <x>]^-1
;
; MODIFICATION HISTORY:
;  December 2010: Written by Chris Beaumont
;-
function ml_exponential, x, xmax, xmin = xmin
  if n_params() ne 2 then begin
     print, 'calling sequence'
     print, ' alpha = ml_exponential(x, xmax)'
     return, !values.f_nan
  endif
  if n_elements(x) eq 0 || n_elements(xmax) eq 0 then $
     message, 'x and xmax must be provided'
  if ~is_scalar(xmax) then $
     message, 'xmax must be a scalar'
  if n_elements(xmin) ne 0 && ~is_scalar(xmin) then $
     message, 'xmin must be a scalar'
  if n_elements(xmin) eq 0 then begin
     xmin = 0
     hit = where(x lt xmax, ct)
  endif else begin
     hit = where(x lt xmax and x gt xmin, ct)
  endelse

  if ct eq 0 then $
     message, 'no data in acceptable range'
  
  return, 1./(xmax - xmin - mean(x[hit]))
end


pro test
  xmax = 20.
  alpha = 2.
  x = arrgen(-30, xmax, nstep = 1000)
  dx = x[1] - x[0]
  y = alpha * exp(alpha * (x - xmax))
  
  cdf = total(y * dx, /cumul)
  
  nsample = 1000
  data = interpol(x, cdf, randomu(seed, nsample))

  h = histogram(data, loc = l, nbin = 30)
  dx = (l[1] - l[0])
  h = h / total(h) / dx
  plot, l, h, psym = 10, /ylog, yra = minmax(h[where(h gt 0)]), $
        charsize = 1.5, tit='Blue=Answer, red=ML fit'

  a = ml_exponential(data, xmax)
  print, a
  oplot, l, a * exp(a * (l - xmax)), color = fsc_color('red'), thick = 3
  oplot, l, alpha * exp(alpha * (l - xmax)), color = fsc_color('royalblue'), $
         thick = 3
end
