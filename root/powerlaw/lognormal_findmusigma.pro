pro lognormal_findmusigma, data, mu, sigma, xmin = xmin, $
                           muguess = muguess,  mu_limits = mu_limits, $
                           sigmaguess = sigmaguess, sigma_limits = sigma_limits, $
                           verbose = verbose, ksd = ksd, _extra = extra, $
                           ad = ad, mad = mad
  
; only consider data above xmin  
  inds = where(data gt xmin,ct)
  if ct eq 0 then begin
     if keyword_set(verbose) then print, 'no data above xmin. Aborting'
     sigma = !values.f_nan
     mu = !values.f_nan
     return
  endif

  fdata = data[inds]

  ;-XXX if xmin = 0, implement analytic solution
  
  p0 = dblarr(2)
  if n_elements(muguess) ne 0  && $
     n_elements(sigmaguess) ne 0 then p0 = [muguess, sigmaguess] else begin
     
     ;-guess based on gaussian fit to log
     logh = histogram(alog(fdata), loc = loc, nbins = 15)
     fit = gaussfit(loc, logh, a, nterms = 3)
     p0 = [a[1], a[2]]
     
  endelse

  doTNMIN = 0
  
  if ~doTNMIN then begin
                                ;- use simpler constrained_min program
     ;- use multimin program
     nan = !values.f_nan
     lobound = [nan, 1d-2]
     hibound = [nan, nan]
     pfit = multimin('lognormal_mle', p0, xmin = xmin, data = fdata, _extra = extra)
;     pfit = constrained_min('lognormal_mle', p0, lobound = lobound, hibound = hibound, $
;                            xmin = xmin, data = fdata, _extra = extra)
     if ~finite(pfit[0]) then begin
     ;pfit = constrained_min('lognormal_mle', p0, lobound = lobound, hibound = hibound, $
     ;                       xmin = xmin, data = fdata, /verbose)
        mu = !values.f_nan
        sigma = !values.f_nan
        ksd = !values.f_nan
        return
     endif else begin
        mu = pfit[0]
        sigma = pfit[1]
     endelse
  endif else begin
     
                                ; Use Craig Marquardt's TNMIN to find the maximum likelihood parameters
     npar    = 2
     parinfo = replicate( { fixed: 0b, $
                            limited: [0b,0b], $
                            limits: dblarr(2), $
                            name : ''} $
                          ,npar)
     
     parinfo[0].name = 'mu'
     parinfo[1].name = 'sigma'
     
                                ; mu
     if keyword_set(mu_limits) then begin
        parinfo[0].limited = [1b, 1b]
        parinfo[0].limits = mu_limits
     endif
     
                                ; sigma
     if keyword_set(sigma_limits) then begin
        parinfo[1].limited = [1b, 1b]
        parinfo[1].limits = sigma_limits
     endif else begin
        parinfo[1].limited = [1b, 0b]
        parinfo[1].limits = [0D, 0D]
     endelse
     
     functargs = {data:double(fdata), xmin:xmin}
     assert, xmin le min(fdata)
     pfit = TNMIN('lognormal_mle',p0, functargs=functargs, parinfo=parinfo, /quiet) ;, /autoderiv)
     
     if n_elements(pfit) ne 2 then begin
        mu = !values.f_nan
        sigma = !values.f_nan
        ksd = 5
        return
     endif
  
     mu    = pfit[0]
     sigma = pfit[1]
  endelse

  test = edf_stats(fdata, 'lognormal_cdf', xmin = xmin, mu= mu, $
                   sigma = sigma, ks = ksd, ad = ad, mad = mad)
;  ksone,fdata, 'lognormal_cdf' , xmin = xmin, mu = mu, sigma = sigma, ksd
  
  return
  
end
