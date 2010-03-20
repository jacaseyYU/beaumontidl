;+
; PURPOSE:
;  This function determines the best fit exponent for a power law
;  distribution. That is, given data assumed to be drawn from the
;  distribution
;     p(x) ~ x^(-alpha), for x >= xmin
;  this function finds the optimal value for alpha. The value for xmin
;  must be provided
;
; CATEGORY:
;  Statistics
;
; CALLING SEQUENCE:
;  result = powerlaw_fitexp(data, xmin, [sigma = sigma, 
;                           ksd = ksd, /discrete, /verbose])
;
; INPUTS:
;  data: A vector of data points drawn from a power law distribution
;  
;  xmin: The powerlaw cutoff value.
;
; KEYWORD PARAMETERS:
;  sigma: Set to a named variable to hold the statistical error on the
;  fitted exponent. 
;
;  ksd: Set to a named variable to hold the KS D statistic for the
;  distance between the data and the best fit power law. This number
;  is given by max[ abs(cdf_data(x) - cdf_model(x)) ] for x >= xmin
;
;  ad: Set to a named variable to hold the Anderson Darling statistic
;      for the fit.
;
;  VERBOSE: print extra information
;
;  DISCRETE: Set this keyword to indicate that data are drawn from a
;  discrete distribution.
; 
; OUTPUTS:
;  The best fit value for alpha. If this cannot be determined, NAN is
;  returned.
;  
; NOTES:
;  This procedure is lifted from Clauset et al. arXiv 0706.1062
;
; MODIFICATION HISTORY:
;  May 2009: Adapted from a paper by Clauset et al. by Chris Beaumont
;  June 2009: Added ad keyword. cnb.
;-
function powerlaw_fitexp, data, xmin, $
                          sigma = sigma, ksd = ksd, ad = ad, mad = mad, $
                          discrete = discrete, verbose = verbose
compile_opt idl2
;on_error, 2
DEBUG = 0
;- check inputs
if n_params() ne 2 then begin
   print, 'powerlaw_fitexp calling sequence:'
   print, 'result = powerlaw_fitexp(data, xming, [sigma = sigma, '
   print, '                         ksd = ksd, /discrete, /verbose])'
   return, !values.f_nan
endif

if n_elements(data) le 1 then message, 'data must be an array'
if keyword_set(discrete) then message, 'Discrete mode not yet supported'
if xmin le 0 then begin
   if keyword_set(verbose) then print, 'xmin must be positive. Aborting'
   return, !values.f_nan
endif

;- perform calculation
good = where(data ge xmin, ct)
if ct eq 0 then begin
   if keyword_set(verbose) then print, 'No data above xmin. Aborting.'
   return, !values.f_nan
endif

;- from equation 3.1
alpha = 1 + ct / (total(alog(data[good]/xmin), /nan))

;- from equation 3.2
sigma = (alpha - 1) / sqrt(ct)

;- calculate KS D and AD statistics
junk = edf_stats(data[good], 'powerlaw_cdf', ks = ksd, ad = ad, mad = mad, $
                xmin = xmin, alpha = alpha)

;sort = sort(data[good])
;sort = (data[good])[sort]
;s = 1 - findgen(ct) / ct
;p = (sort/xmin)^(1 - alpha)
;ksd = max(abs(s-p))

if DEBUG then begin
   plot, sort, s, psym = 4, /xlog, /ylog
   oplot, sort, p, psym = 4, color = fsc_color('blue')
   stop
endif
return, alpha

end
