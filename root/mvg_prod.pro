;+
;
; PURPOSE:
;  MultiVariateGaussian_Product calculates the parameters
;  (i.e. covariance matrix, mean, normalization factor) of the
;  multivariate gaussian obtained by multiplying two other
;  multivariate gaussians together. The two input gaussians are
;  assumed to be normalized.
;
; CATEGORY:
;  statistics
;
; INPUTS:
;  mu1: Means of the first gaussian. An M-vector
;  mu2: Means of the second gaussian. An M-vector
;  covar1: Covariance matrix for the first gaussian. An MxM matrix.
;  covar2: Covariance matrix for the second gaussian. An MxM matrix.
;
; KEYWORD PARAMETERS:
;  volume: Set to return the integral of this multivariate gaussian
;          over all dimensions.
;
; OUTPUTS:
;  mu: The mean of the product gaussian
;  covar: The covariance matrix of the product gaussian
;  norm: A normalization factor (i.e. the constant outside the exponential).
;
; MODIFICATION HISTORY:
;  November 2009: Written by Chris Beaumont
;-
pro mvg_prod, mu1, mu2, covar1, covar2, mu, covar, norm, volume = volume
  compile_opt idl2
  
  ;- check inputs
  if n_params() ne 7 then begin
     print, 'calling sequence'
     print, '  mvg_prod, mu1, mu2, covar1, covar2, mu, covar, norm'
     return
  endif
 
  if size(reform(mu1), /n_dimen) ne 1 || $
     size(reform(mu2), /n_dimen) ne 1 then $
        message, 'mu1 and mu2 must be 1d vectors'

  ndimen = n_elements(mu1)

  s1 = size(covar1)
  s2 = size(covar2)
  if s1[0] ne 2 || s2[0] ne 2 || $
     s1[1] ne ndimen || s1[2] ne ndimen || $
     s2[1] ne ndimen || s2[2] ne ndimen then $
        message, 'covar1 and covar2 must be square matrices, '+$
                 'with the sime dimension as mu1 and mu2'

  ;- do the calculation
  i1 = invert(covar1)
  i2 = invert(covar2)
  covar = invert(i1 + i2)
  m1 = reform(mu1, 1, ndimen)
  m2 = reform(mu2, 1, ndimen)
  mu = covar ## (i1 ## m1 + i2 ## m2)
  denom = (2 * !pi)^ndimen * sqrt(determ(covar1) * determ(covar2))
  numer = transpose(m1) ## i1 ## m1 + $
          transpose(m2) ## i2 ## m2 - $
          transpose(mu) ## (i1 + i2) ## mu
  numer = exp(-.5 * numer)
  norm = (numer / denom)[0]

end
