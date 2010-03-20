function outliercdf_fitcdf, theX, mu, sigma, cdf = cdf
  result = 1
  
  good = where(finite(theX), gct)
  if gct lt 5 then return, result
  x = theX[good]
  sort = sort(x)
  cdf_x = x[sort]
  if ~keyword_set(cdf) then cdf = findgen(gct) / (gct - 1)
  
;- guess mean and sigma
  guess = [median(x), stdev(x)]
  
;-fit a cdf to the data
  fit = lmfit(cdf_x, cdf, guess, function='outliercdf_lmfunc', /double, converge = converge)
  if (converge ne 1) then return, result
  mu = guess[0]
  sigma = guess[1]
  return, 0
  
end
  
  
function outliercdf_lmfunc, x, params
  
  z = (x - params[0]) / (sqrt(2) * params[1])
  eval = .5 * (1 + erf(z))
  dfdu = 1 / sqrt(!dpi) * exp(-z^2) * ( - 1 / (sqrt(2) * params[1]))
  dfds = 1 / sqrt(!dpi) * exp(-z^2) * ( - z / params[1])
  return, [eval, dfdu, dfds]
end

pro outliercdf_plot, theX, result
;- detections must be finite
  good = where(result, gct, complement = bad, ncomp = bct)
  if gct lt 5 then return
  
;-find mean, sigma of good points
  temp = outliercdf_fitcdf(theX, mu, sigma)
  
;- transform data to a cdf
  sort = sort(theX)
  x = theX[sort]
  
  good = where(result[sort], gct, complement = bad, ncomp = bct)
  cdf = findgen(n_elements(x)) / (n_elements(x)-1)
  
  plot, x, cdf, yra = [-.1, 1.1]
  if gct ne 0 then $
     oplot, x[[good]], [cdf[good]], psym = 4, color = fsc_color('green')
  if bct ne 0 then $
     oplot, [x[bad]], [cdf[bad]], psym = 4, color = fsc_color('red')
  oplot, x, gauss_pdf((x - mu) / sigma), color = fsc_color('yellow')
  stop
  
end

function outliercdf, x, status, plot = plot, verbose = verbose, thresh = thresh
  
  SUCCESS = 0
  FAIL = 1
  status = FAIL
  DEBUG = 0
                                ;- check input
  if n_params() lt 1 then begin
     print, 'outliercdf calling sequence:'
     print, 'result = outliercdf(x, [/status, /plot, /verbose, thresh = thresh]'
  endif
  
  sz = n_elements(x)
  if sz lt 5 then begin
     if keyword_set(verbose) then $
        print, 'Not enough points for outlier rejection.'
     return, bytarr(sz)+1B
  endif
  
  thresh = keyword_set(thresh) ? thresh : 3
  FRAC = 0.15                    ;- maximum rejection fraction
  result = bytarr(sz) + 1B
  niter = 0
  status = FAIL
  
                                ;-outlier rejection
detect:
  niter++
  
;-find the 1 sigma position, based on the inner 50%
  good = where(result, gct)
  fit = x[good]
  fit = x[sort(x)]
  fit = fit[ .25 * gct : .75 * gct]
  cdf = findgen(sz) / (sz - 1)
  cdf = cdf[.25 * gct : .75 * gct]
  temp = outliercdf_fitcdf(fit, med, sig, cdf = cdf)
     
  if (temp) then begin
     if keyword_set(verbose) then $
        print, 'Failed to fit cdf to data. Aborting'
     result = FAIL
     return, bytarr(n_elements(x)) + 1B
  endif

  if (DEBUG) then begin
     cdf = findgen(n_elements(x)) / (n_elements(x)-1)
     plot, x[sort(x)], cdf, psym = 4
     cdf_x = findgen(1d3) / (1d3) * range(x) + minmax(x,/nan)
     oplot, cdf_x, gauss_pdf((cdf_x - med) / sig)
     stop
  endif 
  
  result = result and $
           (abs(x - med) lt thresh * sig)
  
;- test for convergence
  good = where(result, gct)
  
  if gct lt ((1-FRAC) * sz) then begin ;- do not reject more than FRAC of data
     if keyword_set(verbose) then $
        print, 'Too many points rejected. Aborting'
     return, result * 0B + 1B
  endif
  
  if niter gt 3 then begin
     if keyword_set(verbose) then $
        print, 'outliercdf did not converge after 3 iterations. aborting'
     return, result * 0B + 1B
  endif
  
  if (abs(stdev(x[good]) - sig) / sig) gt 0.2 then goto, detect
  
                                ;- converged
  status = SUCCESS
  if keyword_set(verbose) then begin
     print, sz - gct, sz, niter, $
            format="('Successful. Rejected ', i3, ' of ', i3, ' data points in ', i2, ' iterations.')"
  endif
  
  if keyword_set(plot) then $
     outliercdf_plot, x, result 
  
  return, result
  
end
  
