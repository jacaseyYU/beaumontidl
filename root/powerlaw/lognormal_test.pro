pro lognormal_test

  ;- getting bad values for high xmin. Plot MLE surface
  sigmas = [.69, 1, 2]
  ; sigmas = sigmas * 0 + .69
  ns = n_elements(sigmas)
  mus = [alog(.079 * 6.7), .05, .5, 1, 5]
;  mus = mus * 0 + alog(.079 * 6.7)
;  mus = alog(.079 * 6.7) + [0,0]
  nm = n_elements(mus)
  xmins = [.1, 0.5, 0, .1, .8]
  nx = n_elements(xmins)

  sigmas = rebin(sigmas, ns, nm, nx)
  mus = rebin(1#mus, ns, nm, nx)
  xmins = rebin(reform(xmins, 1, 1, nx), ns, nm, nx)
  
  sfit = sigmas * 0
  mfit = mus * 0
  xfit = xmins * 0
  lfit = xfit
  d1fit = xfit
  d2fit = xfit
  l = xfit
  d1 = xfit
  d2 = xfit

  t0 = systime(/seconds)

  for i = 0, ns-1, 1 do begin
     for j = 0, nm - 1, 1 do begin
        for k = 0, nx - 1, 1 do begin
           s = sigmas[i,j,k]
           m = mus[i,j,k]
           xmin = xmins[i,j,k]
           data = lognormal_dist(10000, sigma = s , mu = m, xmin = xmin)
           ;h = histogram(alog(data), loc = loc, binsize = .1)
           ;plot, loc, h, /ylog, yra = [1, 1d4], psym = 10
           
           ;sgrid = findgen(20) / 10 + .1
           ;mgrid = findgen(20) / 10 -1 + m
           ;l = findgen(20,20)
           ;for q = 0, 19, 1 do begin
           ;   for u = 0, 19, 1 do begin
           ;      l[q,u] = lognormal_mle([mgrid[q], sgrid[u]], xmin = xmin, data = data)
           ;   endfor
           ;endfor

 ;          stop

           lognormal_fit, data, mu, sigma, xmin = xmin,/verbose, $
                          mctest = mctest, muguess = m, sigmaguess = s
           stop
           return
           stop

           sfit[i,j,k] = sigma
           mfit[i,j,k] = mu
           xfit[i,j,k] = xmin
           fdata = data[where(data ge xmin)]
           l[i,j,k] = lognormal_mle([m,s],dp,data = fdata, xmin = xmin)
           d1[i,j,k] = dp[0]
           d2[i,j,k] = dp[1]
           lfit[i,j,k] = lognormal_mle([mu,sigma], dp, data = fdata, xmin = xmin)
           d1fit[i,j,k] = dp[0]
           d2fit[i,j,k] = dp[1]
;           print, sigma, mc, x
;           print, s, m, x
        endfor
     endfor
  endfor
  t1 = systime(/seconds)
  print, t1 - t0
  
  stop
end
