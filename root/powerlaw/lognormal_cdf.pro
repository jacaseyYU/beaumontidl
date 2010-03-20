;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME: Lognormal_CDF
;
;
;
; PURPOSE:
;          This function returns the cumulative distribution function value for a
;          lognormal probability distribution function valid from xmin to infinity. 
;
;
; CALLING SEQUENCE:
;                   cdf = lognormal_cdf,x,mu=mu,sigma=sigma,xmin=xmin
;
;
; INPUTS:
;          x     = value at which the CDF will be computed
;          sigma = width of lognormal distribution
;          mu    = natural logarithm of the characteristic mass
;          xmin  = lower bound to data
;
;
; OUTPUTS:
;          cdf = the cumulative distribution function
;
;
; EXAMPLE:
;          ksone,data,'lognormal_cdf',xmin=xmin,mu=mu,sigma=sigma,d,p 
;
;  
;
; MODIFICATION HISTORY:
;
;   js: May 2009 - creation
;-
function lognormal_cdf,x,_extra=extra

  if ~keyword_set(extra) then begin
     print, 'extra is not set!'
      mu       = double(alog(0.079))  ; Chabrier 2003
      sigma    = 0.69d        ; Chabrier 2003
      xmin  = 1d
  endif else begin
      mu    = double(extra.mu)
      sigma = double(extra.sigma)
      xmin  = double(extra.xmin)
  endelse


;  C   = sqrt(2.)/(sigma*sqrt(!pi) * erfc((alog(xmin)-mu)/(sqrt(2.)*sigma)))
;  pdf = C/x * exp(-(alog(x) - mu)^2./(2.*sigma^2.))   
;  cdf = sqrt(2.*!pi)*sigma*C/2. * $
;        (erf((alog(x) - mu)/sqrt(2.)*sigma) - erf((alog(xmin) - mu)/sqrt(2.)*sigma))

  ; find normalization at large x
  c = sqrt(2 / !pi) / sigma * (erfc( (alog(xmin)  - mu) / (sqrt(2) * sigma)))^(-1)
  norm = sqrt(!pi / 2) * sigma * C
  assert, norm ne 0

  cdf = (erf( double((alog(x) - mu) / (sqrt(2) * sigma))) - $
         erf( double((alog(xmin) - mu) / (sqrt(2) * sigma))) ) * norm


  return,cdf
end

