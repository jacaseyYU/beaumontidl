pro ncores, resume = resume, restart = restart
  ncores = [100,200,500, 700, 800, 900, 1000, 1200, 1500, 2000]
  tol = ncores * 0 + 1d-3
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
     if ~file_test('ncores.sav') then message, 'cannot resume - no .sav file'
     restore, 'ncores.sav'
     ;- recompile procedures just to be safe
     resolve_all
     istart = i
     goto, iterate
  endif

  nstart = 0L

  mu0    = alog(0.079*6.7)
  sigma0 = 0.69
  xmin0  = 0.5
  
  ;- WEIRD VARIABLE NAMES!!!
  ;- xxDyyF means data drawn from xx distribution, 
  ;- and fit to a yy distribution. xx, yy are pl or ln.

  ;- just check to make sure things aren't getting
  ;- overwritten
  safe_mu = mu0
  safe_sigma = sigma0
  safe_xmin = xmin0
 
  ;- ln data, ln fits
  lnDlnF_mu     = fltarr(sz, nrep)
  lnDlnF_sigma  = fltarr(sz, nrep)
  lnDlnF_mu0    = fltarr(sz, nrep)
  lnDlnF_sigma0 = fltarr(sz, nrep)
  lnDlnF_ksds   = fltarr(sz, nrep)
  lnDlnF_ads    = fltarr(sz, nrep)
  lnDlnF_nfit   = fltarr(sz, nrep)
  lnDlnF_mad    = fltarr(sz, nrep)
  lnDlnF_ml     = fltarr(sz, nrep)

  ;- pl data, ln fits 
  plDlnF_mu     = fltarr(sz, nrep)
  plDlnF_sigma  = fltarr(sz, nrep)
  plDlnF_ksds   = fltarr(sz, nrep)
  plDlnF_ads    = fltarr(sz, nrep)
  plDlnF_nfit   = fltarr(sz, nrep)
  plDlnF_mad    = fltarr(sz, nrep)
  plDlnF_ml     = fltarr(sz, nrep)

  ;- ln data, pl fits
  lnDplF_alpha  = fltarr(sz, nrep)
  lnDplF_xmin   = fltarr(sz, nrep)
  lnDplF_ksds   = fltarr(sz, nrep)
  lnDplF_ads    = fltarr(sz, nrep)
  lnDplF_nfit   = fltarr(sz, nrep)
  lnDplF_mad    = fltarr(sz, nrep)
  lnDplF_ml     = fltarr(sz, nrep)

  ;- pl data, pl fits
  plDplF_alpha  = fltarr(sz, nrep)
  plDplF_xmin   = fltarr(sz, nrep)
  plDplF_alpha0 = fltarr(sz, nrep)
  plDplF_xmin0  = fltarr(sz, nrep)
  plDplF_ksds   = fltarr(sz, nrep)
  plDplF_ads    = fltarr(sz, nrep)
  plDplF_nfit   = fltarr(sz, nrep)
  plDplF_mad    = fltarr(sz, nrep)
  plDplF_ml     = fltarr(sz, nrep)

  istart = 0
  iterate:
  
  t0 = systime(/seconds)
  for i = istart, sz - 1, 1 do begin
     
     ;- Fitting approach
     ;- 1) Draw Muench imf * 6.7. Fit LN
     ;- 2) Draw LN from (1). Fit LN
     ;- 3) Draw LN from mean values of (1) (mu = 1.5, sigma = 1.45)
     ;-       Fit PL
     ;- 4) Draw PL from (3). (straight pl with cutoff)
     ;-       Fit PL

     ;- PL data. LN Fit
     for j = 0, nrep - 1, 1 do begin
        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("PL cores. LN fits. Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
        endif

        cores = cnb_imf(random = ncores[i], /muench) * 6.7  
        
        lognormal_fit, cores, m, s, xmin = 0.5, $
                       ksd = ksd, ad = ad, mad = mad, tol = tol[i], $
                       muguess = .84, sigmaguess = 1.49, verbose = 1

        plDlnF_ksds[i,j] = ksd
        plDlnF_ads[i,j] = ad
        plDlnF_mu[i,j] = m
        plDlnF_mad[i,j] = mad
        plDlnF_sigma[i,j] = abs(s)
        good = where(cores gt 0.5, gct)
        plDlnF_nfit[i,j] = gct

     endfor ;- pl data. ln fit
     
     ;- LN data. LN fit
     good = where(finite(plDlnF_mu[i,*]) and plDlnF_sigma[i,*] gt 0, gct)
     r1 = randomu(seed, nrep) * gct
     for j = 0, nrep - 1, 1 do begin
        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("LN cores. LN fits. Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
        endif
        
        rmu = plDlnF_mu[i,good[r1[j]]]
        rsig = plDlnF_sigma[i, good[r1[j]]]
        rnum = plDlnF_nfit[i, good[r1[j]]]
        cores = lognormal_dist(rnum, sigma = rsig , mu = rmu, xmin = safe_xmin)
        lognormal_fit, cores, m, s, xmin = 0.5, $
                       muguess = rmu, sigmaguess = rsig, $
                       tol = tol[i], ksd = ksd, ad = ad, verbose = 1, $
                       mad = mad
        
        lnDlnF_ksds[i,j]   = ksd
        lnDlnF_ads[i,j]    = ad
        lnDlnF_mu0[i,j]    = rmu
        lnDlnF_sigma0[i,j] = rsig
        lnDlnF_mad[i,j]    = mad
        lnDlnF_mu[i,j]     = m
        lnDlnF_sigma[i,j]  = s
        lnDlnF_nfit[i,j]   = rnum
     endfor ;- LN data. LN fit.

      ;- LN data. PL Fit.
     for j = 0, nrep - 1, 1 do begin

        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("LN cores. PL fits. Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
        endif
        
        rmu = 0.15
        rsig = 1.45
 
        cores = lognormal_dist(ncores[i], sigma = rsig , mu = rmu, xmin = safe_xmin)
        powerlaw, cores, alpha, xmin, /get_xmin, $
                  ksd = ksd, ad = ad, /robust, mad = mad, $
                  xlim = [.5, 5]
        lnDplF_ksds[i,j]   = ksd
        lnDplF_ads[i,j]    = ad
        lnDplF_alpha[i,j]  = alpha
        lnDplF_xmin[i,j]   = xmin
        good = where(cores gt xmin, gct)
        lnDplF_nfit[i,j]   = gct
        lnDplF_mad[i,j]    = mad
    
     endfor ;- LN data. PL Fit.
     
     ;- PL Cores. PL Fits
     for j = 0, nrep - 1, 1 do begin
        good = where(finite(lnDplF_alpha[i,*]), gct)
        r1 = randomu(seed, nrep) * gct
        ralph = lnDplF_alpha[i,good[r1[j]]]
        rxm   = lnDplF_xmin[i, good[r1[j]]]
        rnum  = lnDplF_nfit[i, good[r1[j]]]
        if (j mod 100) eq 0 then begin
           print, ncores[i], j, format='("PL cores, PL Fit: Ncores: ", i5, " Nrep: ", i5)'
           print, time2string(systime(/seconds) - t0)
        endif
        cores = powerlaw_fakegen(alpha = ralph, xmin = rxm, $
                                 ntrial = rnum)

        powerlaw, cores, alpha, rxm, $
                  ksd = ksd, ad = ad, mad = mad
        
        plDplF_ksds[i,j]   = ksd
        plDplF_ads[i,j]    = ad
        plDplF_alpha[i,j]  = alpha
        plDplF_xmin[i,j]   = rxm
        plDplF_xmin0[i,j]  = rxm
        plDplF_alpha0[i,j] = ralph
        plDplF_nfit[i,j]   = rnum
        plDplF_mad[i,j]    = mad
     endfor ;- PL data. PL fit.
 
     save,file='ncores.sav'       
  endfor 
 
  save,file='ncores.sav'       
  
end 
     
