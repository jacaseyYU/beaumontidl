function lognormal_dist,n,mu=mu,sigma=sigma,alpha=alpha,xmin=xmin, $
  plot=plot,print=print, fill = fill, seed = seed

; set default parameters (Chabrier 2002)
  if n_elements(mu) eq 0 then mu = alog(0.079*6.7)
  if ~keyword_set(sigma) then sigma = 0.69
  if n_elements(xmin) eq 0 then xmin = 0.1
  if ~keyword_set(n) then n = 100.

  startt = systime(/sec)

; determine minimum r for given xmin
  rmin = (alog(xmin)-mu)/sigma
; try to predict how big randomn vector must be to produce n elements above xmin
; (overshoot by 20%)
  nguess = 1.2*n/erfc(rmin)
  rand = randomn(seed,nguess)
  inds = where(rand ge rmin,ct)
  rand = rand[inds]

; if there was not enough samples, fill in the rest of random vector
  if ct lt n then begin
      while ct lt n do begin
          if keyword_set(print) then $
            print,'LOGNORMAL_DIST: iterating to build up sample size ...'
          r = randomn(seed,0.5*nguess)
          inds = where(r gt rmin,ct1)
          if ct1 gt 0 then rand = [rand,r[inds]]
          ct = n_elements(rand)
      endwhile
  endif 

; choose first n randoms above rmin
  rand = rand[0:n-1]
  
; turn random numbers into masses
  data =  exp(mu+sigma*rand)

; clock
  deltat = systime(/sec) - startt
  if keyword_set(print) then print,'Created '+str(n)+' cores in '+str(deltat)+' seconds'

  if xmin gt 0 && keyword_set(fill) then begin ;- fill in data below xmin with a flat distribution
     rand = randomu(seed, n_elements(data))
     good = where(rand ge .5, ct)
     if ct ne 0 then begin
        data[good] = (randomu(seed, ct) > .001) * xmin
     endif
  endif

; plot
  if keyword_set(plot) then begin
      plothist,alog(data),xh,yh,/ylog,/auto

      lnx = makearr(100,!x.crange[0],!x.crange[1])
      model = exp(-(lnx-mu)^2./(2*sigma^2.))
      modelh = cspline(lnx,model,xh)
      inds = where(xh gt xmin)
      noff = 1000
      guess = median(yh[inds]/modelh[inds])
      norm = makearr(noff,guess*0.25,guess*2.)
      chisq = fltarr(noff)
      for i = 0, noff-1 do $
        chisq[i] = total((yh[inds] - norm[i]*modelh[inds])^2./(norm[i]*modelh[inds]))
      minchi = min(chisq,minind)
      norm = norm[minind]

      oplot,lnx,norm*model, color = fsc_color('brown'), thick = 2

      plots,[alog(xmin),alog(xmin)],!y.crange,linestyle=1, color = fsc_color('blue')

  endif
  
  return,data
end
