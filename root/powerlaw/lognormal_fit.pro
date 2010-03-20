;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME: Lognormal_Fit
;
;
;
; PURPOSE:
;          This procedure will return the maximum likelihood values for the
;          characteristic value and the standard deviation of the data assuming
;          a lognormal form for the distribution.
;
;
; CALLING SEQUENCE:
;
;                  lognormal_fit, data, mu, sigma, mu_err, sigma_err,
;                                [d0, prob0, dfrac, prob, p0=p0, $
;                                xmin=xmin, /test, /plot]
;
; INPUTS:
;          data:    the data you want to fit
;
; OPTIONAL INPUTS:
;
;          xmin:         the minimum x value of the data to consider.
;          p0:           the intial guess for the lognormal parameters
;                        [mu, sigma]
;          mu_limits:    limits to the logarithm of the characteristic mass
;                        in the fitting routine, [mu_lo,mu_hi]
;          sigma_limits: limits to the standard deviation in the fitting
;                        routine, [sigma_lo,sigma_hi]
;
;
; KEYWORD PARAMETERS:
;                     test:      set this keyword to test the lognormal hypothesis
;                                using a Monte Carlo technique.
;                     plot:      set to see a plot of the data and the best fit
;                     verbose:   set to see output messages.
;
;
; OUTPUTS:
;          mu:        the most likely characteristic mass
;          sigma:     the most likely lognormal standard deviation of data.
;          mu_err:    the estimated error on mu
;          sigma_err: the estimated error on sigma
;          d0:    this is the two sided KS statistic for the most likely
;                 lognormal and the data.
;          prob0: this is the KS probability that the data are drawn from a lognormal
;                 distribution as defined by the most likely lognormal index.
;          prob:  this is the probability that a lognormal is the correct functional
;                 form for the data.
;
;
; OPTIONAL OUTPUTS:
;          sigx:  the error on the xmin value if get_xmin is used
;          sigi:  the additional error on sigma induced by the uncertainty of xmin.
;
;
; SIDE EFFECTS:
;               uses window lun 22, 23, and 24 if plot keyword is set
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;   js: May 2009 - creation
;-
pro lognormal_fit, data, mu, sigma, ksd = ksd, $
                   xmin = xmin, get_xmin = get_xmin, $
                   muguess = muguess, mu_limits = mu_limits, $
                   sigmaguess = sigmaguess, sigma_limits = sigma_limits, $
                   mctest = mctest, $
                   verbose = verbose, robust = robust, _extra = extra, $
                   ad = ad, mad = mad


  ;- determine xmin
  if keyword_set(get_xmin) then begin
          
     if keyword_set(verbose) then print, 'finding x_min'
     ntest = keyword_set(robust) ? 200 : 20
     sorted = sort(data)
     sz = n_elements(data)
     loind = 0
     hiind = (keyword_set(robust) ? .95 * sz : .9 * sz) < (sz - 5)
     
     xlo = data[sorted[loind]]
     xhi = data[sorted[hiind]]
     xtest = findgen(ntest) / (ntest - 1) * (xhi - xlo) + xlo

     ksds = fltarr(ntest)
     for i = 0, ntest - 1, 1 do begin
        lognormal_findmusigma, data, mu, sigma, xmin = xtest[i], $
                               muguess = muguess, sigmaguess = sigmaguess, $
                               sigma_limits = sigma_limits, $
                               mu_limits = mu_limits, verbose = verbose, ksd = ks, _extra = extra
        ksds[i] = ks
     endfor
     
     ;- refine coarse grid to get best xmin and alpha
     lo = min(ksds, midloc, /nan)
     
     ;- occasionally, there are multiple adjacent ksd minima.
     ;- Anticipate this and bracket the minimum correctly
     loloc = midloc
     while((loloc gt 0) && (ksds[loloc] eq lo)) do loloc--
     
     hiloc = midloc
     while((hiloc lt (ntest-1)) && (ksds[hiloc] eq lo)) do hiloc++
     
     ;- handle the case where we didn't bracket a minimum
     ;- because we hit the boundary
     if (ksds[loloc] eq ksds[midloc]) then begin
        ;- this is fine - xmin seems to be below lowest data point
        xmin = xtest[midloc]
     endif else if (ksds[hiloc] eq ksds[midloc]) then begin
        ;- maybe something should be done here. But it suggests 
        ;- that almost all of the data is below the cutoff.
        ;- This probably means something is wrong (e.g. not powerlaw data)
        xmin = xtest[midloc]
     endif else begin
        xmin = lognormal_xmin_golden(data, $
                                    xtest[loloc], $
                                    xtest[midloc], $
                                    xtest[hiloc], $
                                     tol = .05, verbose = verbose, $
                                    muguess = muguess, sigmaguess = sigmaguess, $
                                    mu_limits = mu_limits, sigma_limits = sigma_limits)
     endelse
     if keyword_set(verbose) then print, 'Done. Xmin = '+strtrim(xmin,2)
  endif ;- keyword_set(get_xmin)
  
  ;- use best xmin guess to find mu and sigma
  lognormal_findmusigma, data, mu, sigma, xmin = xmin, $
                         muguess = muguess, sigmaguess = sigmaguess, $
                         sigma_limits = sigma_limits, $
                         mu_limits = mu_limits, verbose = verbose, ksd = ksd,$
                         ad = ad, mad = mad, _extra = extra
    
  ;- test for failure
  if ~finite(mu) || ~finite(sigma) || ~finite(ksd) then begin
     mu = !values.f_nan
     sigma = !values.f_nan
     ksd = !values.f_nan
     mctest = !values.f_nan
     print, 'FAILED FIT!'
     return
  endif

  if arg_present(mctest) then begin
     nrep = 2500.
     if keyword_set(verbose) then begin
        print, 'Starting mc loop'
        report = obj_new('looplister', nrep, 10)
     endif
     synth = data * 0
     ndata = n_elements(data)
     good = where(data gt xmin, complement = bad, ncomplement = nbad)
     ksds = fltarr(nrep)
     for i = 0,nrep-1 do begin
        if keyword_set(verbose) then report -> report, i
        ;- synthesize data
        r1 = randomu(seed, ndata) * ndata
        hi = where(r1 gt nbad, nhi, complement = lo, ncomp = nlo)
        if nhi ne 0 then $
           synth[hi] = lognormal_dist(nhi,mu=mu,sigma=sigma,xmin=xmin)
        if nlo ne 0 then $
           synth[lo] = data[bad[randomu(seed, nlo) * nbad]]
        
        lognormal_fit, synth, synth_mu, synth_sigma, ksd = k, $
                       xmin = xmin, get_xmin = get_xmin, $
                       muguess = mu, mu_limits = mu_limits, $
                       sigmaguess = sigma, sigma_limits = sigma_limits, _extra = extra

        ksds[i] = k
     endfor
     if keyword_set(verbose) then obj_destroy, report
     ngood = total(finite(ksds))
     mctest = 1D * total(ksds gt ksd) / ngood
     if ngood lt 1500 then begin
        print, 'WARNING: Many failed LN fits during MC testing: ', 2500 - ngood
     endif
  endif 
  return
end
