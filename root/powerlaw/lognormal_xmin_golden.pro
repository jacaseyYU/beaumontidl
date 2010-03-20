function lognormal_ks, x
compile_opt idl2

common lognormal_data, data, muguess, sigmaguess, mu_limits, sigma_limits

if n_elements(data) eq 0 then $
   message, 'you must create the lognormal_ks common block first!'


lognormal_findmusigma, data, mu, sigma, xmin = x, $
                       muguess = muguess, sigmaguess = sigmaguess, $
                       sigma_limits = sigma_limits, $
                       mu_limits = mu_limits, verbose = verbose, ksd = ksd


return, ksd

end

function lognormal_xmin_golden, data, xlo, xmid, xhi, $
                                muguess = muguess, sigmaguess = sigmaguess, $
                                sigma_limits = sigma_limits, mu_limits = mu_limits, $
                                tol = tol, verbose = verbose
compile_opt idl2
;on_error, 2

;- check inputs
if n_params() ne 4 then begin
   print, 'lognormal_xmin_golden calling sequence:'
   print, 'result = lognormal_xmin_golden(data, xlo, xmid, xhi)'
   return, !values.f_nan
endif

if (xmid le xlo) or (xmid ge xhi) then $
   message, 'Input guesses must satisfy xlo < xmid < xhi'

lognormal_findmusigma, data, mu, sigma, xmin = xlo, $
                       muguess = muguess, sigmaguess = sigmaguess, $
                       sigma_limits = sigma_limits, $
                       mu_limits = mu_limits, verbose = verbose, ksd = k1

lognormal_findmusigma, data, mu, sigma, xmin = xmid, $
                       muguess = muguess, sigmaguess = sigmaguess, $
                       sigma_limits = sigma_limits, $
                       mu_limits = mu_limits, verbose = verbose, ksd = k2

lognormal_findmusigma, data, mu, sigma, xmin = xhi, $
                       muguess = muguess, sigmaguess = sigmaguess, $
                       sigma_limits = sigma_limits, $
                       mu_limits = mu_limits, verbose = verbose, ksd = k3
if (k2 gt k1) or (k2 gt k3) then $
   message, 'Input guesses must satisfy KS(xmid) < Min (KS(xlow), KS(xhi))'

;- set up common block for lognormal_ks
common lognormal_data, theData, the_mu_guess, the_sigma_guess, the_mu_limits, the_sigma_limits
theData = data
if n_elements(muguess)      ne 0 then the_mu_guess     = muguess
if n_elements(mu_limits)    ne 0 then the_mu_limits    = mu_limits
if n_elements(sigmaguess)   ne 0 then the_sigma_guess  = sigmaguess
if n_elements(sigma_limits) ne 0 then the_sigma_limits = sigma_limits

;- find xmin
xmin = goldenmin('lognormal_ks', xlo, xmid, xhi, tol = tol, verbose = verbose)

return, xmin
end

