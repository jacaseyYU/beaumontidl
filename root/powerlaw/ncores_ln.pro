pro ncores_ln, resume = resume, restart = restart
  ncores = [100,200,500,600, 700, 800, 900, 1000]
  tol = ncores * 0 + .01
  sz = n_elements(ncores)
  nrep  = 5000L
  
  if ~keyword_set(restart) && ~keyword_set(resume) then begin
     print, 'set either /restart or /resume'
     return
  endif

;  if keyword_set(restart) then begin
;     start = ''
;     read, start, prompt = 'Starting a new simulation will erase any old save files. Are you sure (y/n)?'
;     if start eq 'n' then return $
;     else if start eq 'y' then begin
;     endif else begin
;        print, 'unrecognized option'
;        return
;     endelse
;  endif

  if keyword_set(resume) then begin
     if ~file_test('ncores_ln.sav') then message, 'cannot resume - no .sav file'
     restore, 'ncores_ln.sav'
     resolve_all, class='looplister'
     nstart = n
     goto, iterate
  endif

  nstart = 0L

  mu0    = alog(0.079*6.7)
  sigma0 = 0.69
  xmin0  = 0.5
  
  ;- just check to make sure things aren't getting
  ;- overwritten
  safe_mu = mu0
  safe_sigma = sigma0
  safe_xmin = xmin0
 
  ;- fits to lognormal data
  ln_mu    = fltarr(sz, nrep)
  ln_sigma = fltarr(sz, nrep)
  ln_mu0   = fltarr(sz, nrep) ;- the true values
  ln_sigma0= fltarr(sz, nrep) ;- the true values
  ln_ksds  = fltarr(sz, nrep)
  ln_ads   = fltarr(sz, nrep)

  ;- fits to pl data
  pl_mu    = fltarr(sz, nrep)
  pl_sigma = fltarr(sz, nrep)
  pl_ksds  = fltarr(sz, nrep)
  pl_ads   = fltarr(sz, nrep)

  iterate:

  jstart = nstart mod nrep
  istart = nstart / nrep
  n = nstart

  t0 = systime(/seconds)
  for i = istart, sz - 1, 1 do begin
     
     print, 'fitting PL cores'
     ;- simulate PL data and fit
     for j = jstart, nrep - 1, 1 do begin
        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("PL fitting: Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
           save, file='ncores_ln.sav'
        endif

        n++
        cores = cnb_imf(random = ncores[i], /muench) * 6.7  
        lognormal_fit, cores, m, s, xmin = 0.5, $
                       ksd = ksd, ad = ad, tol = tol[i], $
                       muguess = .84, sigmaguess = 1.49
        pl_ksds[i,j]  = ksd
        pl_ads[i,j]   = ad
        pl_mu[i,j]    = m
        pl_sigma[i,j] = s
     endfor

     ;- need to reset jstart here
     jstart = 0

     print, 'fitting LN cores'
     good = where(finite(pl_mu[i,*]), gct)
     r1 = randomu(seed, nrep) * gct
     ;- simulate LN data and fit
     for j = 0, nrep - 1, 1 do begin
        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("PL fitting: Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
        endif

        rmu = pl_mu[i,good[r1[j]]]
        rsig = pl_sigma[i, good[r1[j]]]
        
        cores = lognormal_dist(ncores[i], sigma = rsig , mu = rmu, xmin = safe_xmin)
        lognormal_fit, cores, m, s, xmin = 0.5, $
                       muguess = rmu, sigmaguess = rsig, $
                       tol = tol[i], ksd = ksd, ad = ad
        
        ln_ksds[i,j]   = ksd
        ln_ads[i,j]    = ad
        ln_mu0[i,j]    = rmu
        ln_sigma0[i,j] = rsig
        ln_mu[i,j]     = m
        ln_sigma[i,j]  = s
     endfor
     save,file='ncores_ln.sav'       
  endfor  
  save,file='ncores_ln.sav'       
  
end 
     
