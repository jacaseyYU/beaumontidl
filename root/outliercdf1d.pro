pro outliercdf_plot, x, y, result, thresh = thresh
  if keyword_set(win) then wset, win
  good = where(result, gct, complement= bad, ncomp = bct)
  plot, x, y, /nodata, position = [.05, .05, .7, .7]
  if gct ne 0 then begin
     oplot, x[good], y[good], psym = 4, color = fsc_color('green')
  endif
  if bct ne 0 then begin
     oplot, x[bad], y[bad], psym = 4, color = fsc_color('red')
  endif
;  xcut = minmax(x[good])
;  hx = histogram(x, loc = xloc, binsize = range(x) / n_elements(x) / 10)
;  hy = histogram(y, loc = yloc, binsize = range(y) / n_elements(y) / 10)
;  !p.multi = [0,1,2]
;  sigma = range(xcut) / (2 * thresh)
;  
;  plot, xloc, 1D * total(hx, /cumul) / total(hx)
;  oplot, xcut[0]*[1,1], [0,3], color = fsc_color('red')
;  oplot, xcut[1]*[1,1], [0,3], color = fsc_color('red')
;  oplot, xloc, gauss_pdf((xloc - median(x[good])) / sigma), color = fsc_color('orange')
;  !p.multi = 0
end

function outliercdf, x, status, plot = plot, verbose = verbose, thresh = thresh
  
    SUCCESS = 0
    FAIL = 1
    status = FAIL
    
  ;- check input
  if n_params() lt 1 then begin
     print, 'outliercdf calling sequence:'
     print, 'result = outliercdf(x, [/status, /plot, /verbose, thresh = thresh]'
  endif
  
  sz = n_elements(x)
  if sz lt 5 then begin
     message, /continue, 'Not enough points for outlier rejection.'
     return, x * 1B
  endif
  
  thresh = keyword_set(thresh) ? thresh : 3
  FRAC = 0.1                    ;- maximum rejection fraction
  result = bytarr(sz) + 1B
  niter = 0
  status = FAIL

  ;-outlier rejection
detect:
  niter++
  good = where(result, gct)
  cdf_x = x[good]
  cdf_x = cdf_x[sort(cdf_x)]
  cdf = findgen(gct) / (gct - 1)
  
;- find the median
  med = interpol(cdf_x, cdf, .5)
  
;-find the 1 sigma position
  sig = interpol(cdf_x, cdf, gauss_pdf(1)) - medx
  
  result = result and $
           (abs(x - medx) lt thresh * xsig) and $
           (abs(y - medy) lt thresh * ysig)
  
;- test for convergence
  good = where(result, gct)
    
  if gct lt ((1-FRAC) * sz) then begin ;- do not reject more than FRAC of data
     if keyword_set(verbose) then $
        message, /continue, 'Too many points rejected. Aborting'
     return, result
  endif
  
  if niter gt 3 then begin
     if keyword_set(verbose) then $
        message, /continue, 'outliercdf did not converge after 3 iterations. aborting'
     return, result * 1B
  endif
  
  if abs(stdev(x[good]) - xsig) / xsig gt 0.2 || $
     abs(stdev(y[good]) - ysig) / ysig gt 0.2 then $
        goto, detect
  
  ;- converged
  status = SUCCESS
  if keyword_set(plot) then outliercdf_plot, x, y, result, win = win, thresh = thresh
  if keyword_set(verbose) then begin
     print, sz - gct, sz, niter, $
            format="('Successful. Rejected ', i3, ' of ', i3, ' data points in ', i2, ' iterations.')"
  endif
  
  return, result
end
