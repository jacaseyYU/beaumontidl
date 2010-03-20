;+
; PURPOSE:
;  This function uses the Kolmogorov-Smirnov statistic D, along with
;  the golden minimization algorithm, to find best fit cutoff value
;  for a power law distribution. That is, given data assumed to be
;  drawn from the distribution
;    p(x) ~ x^(-alpha), for x >= xmin
;  the function finds the optimal value for xmin. Three guesses for
;  xmin which bracket the best value must be provided.
;
; CATEGORY:
;  Statistics
;
; CALLING SEQUENCE:
;  result = powerlaw_xmin_golden(data, xlo, xmid, xhi,
;                                [alpha = alpha, tol = tol, /verbose])
;
; INPUTS:
;  data: The data assumed to be drawn from a power law distribution
;  xlo: The first of three points bracketing xmin
;  xmid: The second of three points braceting xmin. This must satisfy
;        xlo < xmid < xhi, KS(xmid) < min ( KS(xlo), KS(xhi) )
;  xhi: The final point bracketing xmin
;
; KEYWORD PARAMETERS:
;  alpha: Set to a named variable to hold the best fit value for alpha
;  at xmin. 
;
;  tol: The desired fractional precision of the minimum
;  coordinate. Defaults to .001 if absent
;  
;  verbose: Print extra information
;
; OUTPUTS:
;  The optimal estimator for xmin
;
; NOTES:
;  This procedure is lifted from Clauset et al. arXiv 0706.1062
;  
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont based on Clauset et al.
;- 
function powerlaw_xmin_golden, data, xlo, xmid, xhi, $
                               alpha = alpha, tol = tol, verbose = verbose
compile_opt idl2
;on_error, 2

;- check inputs
if n_params() ne 4 then begin
   print, 'powerlaw_xmin_golden calling sequence:'
   print, 'result = powerlaw_xmin_golden(data, xlo, xmid, xhi, '
   print, '                              [alpha = alpha, tol = tol'
   print, '                               /verbose]'
   return, !values.f_nan
endif

if (xmid le xlo) or (xmid ge xhi) then $
   message, 'Input guesses must satisfy xlo < xmid < xhi'

a1 = powerlaw_fitexp(data, xlo, ksd = k1, verbose = verbose)
a2 = powerlaw_fitexp(data, xmid, ksd = k2, verbose = verbose)
a3 = powerlaw_fitexp(data, xhi, ksd = k3, verbose = verbose)

if (k2 gt k1) or (k2 gt k3) then $
   message, 'Input guesses must satisfy KS(xmid) < Min (KS(xlow), KS(xhi))'

;- set up common block for powerlaw_ks
common powerlaw_data, theData
theData = data

;- find xmin
xmin = goldenmin('powerlaw_ks', xlo, xmid, xhi, tol = tol, verbose = verbose)

if keyword_set(alpha) then alpha = powerlaw_fitexp(data, xlo)

return, xmin
end

