;- filter, flag, fit parallax to data

pro reduce_object, m, t, $
                   xerr, yerr, $
                   obj_flags, flags, mags, $
                   pos, pm, par, $
                   bin = bin, pmplot = pmplot, parplot = parplot, $
                   verbose = verbose, olderror = olderror, $
                   _extra = extra, cv = cv
  compile_opt idl2

  ;- check inputs
  if n_params() ne 10 then begin
     print, 'calling sequence:'
     print, ' reduce_object, m, t, xerr, yerr,'
     print, '                obj_flags, flags, mags, pos,  pm, par, '
     print, '                [/bin, /pmplot, /parplot, /verbose, _extra, cv = cv'
     return
  endif

  num = n_elements(m)
  if n_elements(xerr) ne num || $
     n_elements(yerr) ne num then begin 
     message, 'xerr and yerr arrays not the correct length'
  endif


  obj_flags = '0'xl
  flags = ulonarr(n_elements(m)) + '100'x
  pos = {posfit}
  pm = {pmfit}
  par = {parfit}
  mags = fltarr(4)

;- extra object flags
;MAG_SKIP   = '1'x               ;- skipped magnitude outlier detection                  
;MAG_FAIL   = '2'x               ;- mag outlier detection failed
;SKY_SKIP   = '4'x               ;- skipped sky outlier detection
;SKY_FAIL   = '8'x               ;- sky outlier detection failed
  OBJ_SKIP =  '10'xl            ;- skipped analysis on this object
  OBJ_FAIL =  '20'xl            ;- fitting average position failed
  PM_SKIP =   '40'xl            ;- skipped pm fitting
  PM_FAIL  =  '80'xl            ;- pm measurement failed
  PAR_SKIP = '100'xl            ;- skipped parallax measurement
  PAR_FAIL = '200'xl            ;- unable to fit a parallax / pm curve to data
  PAR_FIT  = '400'xl            ;- succesfully fit parallax

  
  lo = t.off_measure
  hi = t.nmeasure - 1 + lo
  
   ;- skip objects with too few detections
  if (hi - lo) lt 45 then begin
     if keyword_set(verbose) then print, 'Too few objects. Skipping analysis'
     obj_flags = OBJ_SKIP
     return
  endif
    
   ;- filter measurements
  for j = 1, 5, 1 do begin
     hit = where((m.photcode / 100) eq j, ct)
     if ct eq 0 then continue
     subm = m[hit]
     flags[hit] = dvofilter(subm, oflag)
     obj_flags = obj_flags or oflag
     ;- XXX assumes we're skipping U?
     mags[j-2] = wmean(subm.mag, subm.mag_err, /nan)
  endfor
  assert, max((abs(m.d_ra) gt 1) and (flags eq 0)) eq 0
  assert, max((abs(m.d_dec) gt 1) and (flags eq 0)) eq 0


   ;- fit astrometry to good measurements
  good = where(flags eq 0 and finite(xerr) and finite(yerr), ct, $
              complement = bad, ncomp = nbad)
  if nbad ne 0 then flags[bad] = flags[bad] or '100'xl

  if ct lt 5 then begin
     if keyword_set(verbose) then $
        print, 'Too many objects flagged as bad. Skipping analysis'
     obj_flags = obj_flags or OBJ_SKIP
     return
  endif
  
  ra  = t.ra  - m[good].d_ra  / 3600
  dec = t.dec - m[good].d_dec / 3600
   
  if keyword_set(olderror) then begin
     floor = .0149666
     dra = sqrt((floor / 3600)^2 + (m[good].x_ccd_err  * .187 / 36d4)^2)
     ddec = sqrt((floor / 3600)^2 + (m[good].y_ccd_err * .187 / 36d4)^2)
  endif else begin
     dra  = xerr[good] / 3600
     ddec = yerr[good] / 3600
  endelse

  jd = linux2jd(m[good].time)
  
   ;- bin by dates
  if keyword_set(bin) then begin
     bin_by_date, jd, ra, dra, 45, jdbin, rabin, drabin, pop, /noweight
     bin_by_date, jd, dec, ddec, 45, jdbin, decbin, ddecbin, pop, /noweight
     jd = jdbin
     ra = rabin
     dra = drabin
     dec = decbin
     ddec = ddecbin
  endif
  
  if ~keyword_set(cv) then cv = 1
  pos = replicate({posfit}, cv)
  pm = replicate({pmfit}, cv)
  par = replicate({parfit}, cv)

  for i = 0, cv - 1, 1 do begin
     ind = indgen((n_elements(ra) - 1) / cv) * cv + i
     subjd = jd[ind]
     subra = ra[ind]
     subdec = dec[ind]
     subdra = dra[ind]
     subddec = ddec[ind]
  
     pos[i] = fit_pos(subra, subdec, subdra, subddec, status, verbose = verbose, clip = 5)
     if (status eq 0) then begin
        obj_flags = obj_flags or OBJ_FAIL
     endif
     
     pm[i] = fit_pm(subjd, subra, subdec, subdra, subddec, status, verbose = verbose, clip =5)
     if (status eq 0) then begin
        obj_flags = obj_flags or PM_FAIL
     endif
     
     if keyword_set(pmplot) then begin
        plot_pmpar, ra, dec, dra, ddec, jd, pm, $
                    pop = pop, _extra = extra
     endif
     
     
     par[i] = fit_pmpar(subjd, subra, subdec, subdra, subddec, status, verbose = verbose, $
                     clip = 5, included = included)
     if (status eq 0) then $
        obj_flags = obj_flags or PAR_FAIL $
     else $
        obj_flags = obj_flags or PAR_FIT
     
     if keyword_set(parplot) then begin
        if keyword_set(extra) then begin
           extra1 = extra
           extra2 = extra
           names = tag_names(extra)
           ps_pos = where(strmatch(names, 'PS'), posct)
           if posct ne 0 then begin
              extra1.ps = extra1.ps+'.1'
              extra2.ps = extra2.ps+'.2'
           endif
        endif
        plot_pmpar, ra, dec, dra, ddec, jd, par, $
                    pop = pop, _extra = extra1, included = included
        
        plot_pmpar_2, ra, dec, dra, ddec, jd, par, $
                      pop = pop, _extra = extra2, included = included
        print, par.chisq / par.ndof
     endif 
  endfor 
  
  return
end 
