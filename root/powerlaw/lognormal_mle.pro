;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME: Lognormal_MLE
;
;
;
; PURPOSE:
;          The maximum likelihood estimator for a set of data assuming a lognormal
;          distribution. Partial derivatives provided.
;
;
; CALLING SEQUENCE:
;                   mle = lognormal_mle,p,dp,data=data,xmin=xmin
;
;
; INPUTS:
;          p     = logarithmic characteristic mass and standard deviation
;                  [mu, sigma]
;          dp    = the partial derivatives of the MLE for the specified
;                  parameters and data
;          data  = the data
;          xmin  = only data with values above xmin are considered
;
;
; OUTPUTS:
;          MLE = -2 ln(product(p))
;
;
; MODIFICATION HISTORY:
;
;   js: May 2009 - creation
;-
function lognormal_MLE,p,dp,data=x, xmin = xmin, _extra=extra
  
  if (n_elements(xmin) eq 0) then begin
     print, 'xmin not defined:', n_elements(xmin)
     stop
     xmin = 1
  endif else xmin = double(xmin)

  mu    = double( p[0] )
  sigma = double( p[1] )
  assert, min(x,/nan) ge xmin

;  if sigma lt 0 then begin
;     print, 'sigma is negative'
;     dp = !values.f_nan + [0,0]
;     return, !values.f_nan
;  endif

; normalization constant
;  C = double( sqrt(2.)/(sigma*sqrt(!pi)) / erfc((alog(xmin)-mu)/(sqrt(2.)*sigma)))
  ;XXX attempt to allow negative sigmas
  C = double( sqrt(2.)/(abs(sigma)*sqrt(!pi)) / erfc((alog(xmin)-mu)/(sqrt(2.)*abs(sigma))))

; MLE = -2*alog(Product(p(x)))
  MLE = -2d * total( alog(C) - alog(x) - (alog(x) - mu)^2./(2.*sigma^2.))

  ;Partial derivatives
  if n_params() eq 1 then return, MLE
  dp = fltarr(2)

  ;- special case: xmin = 0
  if xmin eq 0 then begin
     dp[0] = -2D * total((alog(x) - mu) / sigma^2)
     dp[1] = -2D * total(-1/sigma + (alog(x) - mu)^2 / sigma^3)
     print, 'xmin = 0'
  endif else begin
     lambda = (alog(xmin) - mu) / (sqrt(2) * sigma)
  
     ; partial derivative wrt mu
     dp[0] = -2d * total( - sqrt(2 / !pi / sigma^2D) * $
                          exp(-lambda^2) / erfc(lambda) + $
                          (alog(x) - mu) / sigma^2)
     
                                ; partial derivative wrt sigma
     dp[1] = -2D * total(-1 / sigma - 2 / (sqrt(!pi) * sigma) / $
                         erfc(lambda) * lambda * exp(-lambda^2) + $
                         (alog(x) - mu)^2D / sigma^3D)
  endelse
  return,MLE

end
