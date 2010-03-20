;+
; PURPOSE:
;  This procedure robustly fits data to a power law distribution. It
;  is based on algorithms described in Clauset et al 2009
;  arXiv0706.1062. The procedure finds the values (and statistical
;  uncertainties) for xmin and alpha to maximize agreement between the
;  data and its presumed pdf
;       p(x) = (x / xmin)^(-alpha) for x >= xmin
; 
;  Optionally, this routine will also test, in a Monte Carlo fashion,
;  whether a power law distribution is a good fit to the data.
;
; CATEGORY:
;  power law, statistics
;
; CALLING SEQUENCE:
;   powerlaw, data, alpha, xmin, 
;             [/get_xmin, 
;              dalpha = dalpha, 
;              dxmin = dxmin,
;              ksd = ksd,
;              mctest = mctest,
;              /verbose, /robust, 
;               xlim = xlim]
;              
; INPUTS:
;  data: Data assumed to be drawn from a power law distribution
;  xmin: If get_xmin is not set, then use this value
;        for xmin instead of fitting to it. 
;
; KEYWORD PARAMETERS:
;  get_xmin: If set, then fit to xmin. 
;
;  dalpha: Set to a variable to hold the error on alpha
;   dxmin: Set to a variable to hold the error on xmin
;     ksd: Set to a variable to hold the ks statistic of this fit
;      ad: Set to a variable to hold the anderson-darling statistic of
;          the fit.
;  mctest: Set this kewyword to test, in a Monte Carlo fashion,
;          whether a power law is a good description of the data. In
;          this case, the value of mctest will be the percentage of
;          time that powerlaw distributed data disagrees with a
;          powerlaw fit as badly as the actual data does.
;  verbose: Print information about the process
;  robust: Use a slower but more reliable technique to find xmin.
;    xlim: Constrain xmin to be between the values of this 2 element array.
;
; TODO:
;  Finding the best value for xmin needs to be improved upon.
;
; SEE ALSO:
;  powerlaw_xmin_golden, powerlaw_fitexp
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;  June 2009: Added AD keyword. Added xlim keyword. cnb.
;-
pro powerlaw, data, alpha, xmin, $
              get_xmin = get_xmin, $
              dalpha = dalpha, $
              dxmin = dxmin, $
              ksd = ksd, $
              ad = ad, $
              mctest = mctest, $
              verbose = verbose, $
              robust = robust, $
              xlim = xlim, $
              mad = mad

  compile_opt idl2
;on_error, 2

  ;- check inputs
  if n_params() ne 3 then begin
     print, 'powerlaw calling sequence:'
     print, 'powerlaw, data, alpha, xmin, [/get_xmin, '
     print, ' dalpha = dalpha, dxmin = dxmin, ksd = ksd, '
     print, ' ad = ad, mctest = mctest, /verbose, xlim = xlim]'
     return
  endif

  sz = n_elements(data)
  if n_elements(xmin) eq 0 && ~keyword_set(get_xmin) then $
     message, 'You must provide xmin, or use /get_xmin'

  if sz le 1 then $
     message, 'data must be an array'

  if ~arg_present(alpha) then $
     message, /continue, 'warning: alpha not passed by reference. No way to pass alpha back'

  ;- determine xmin
  if keyword_set(get_xmin) then begin
    ;-XXX think of how to better select test values
     ntest = keyword_set(robust) ? 200 : 20
     sorted = sort(data)
     loind = 0
     hiind = (keyword_set(robust) ? .95 * sz : .9 * sz) < (sz - 20)
     
     xlo = data[sorted[loind]]
     xhi = data[sorted[hiind]]
     if keyword_set(xlim) then begin
        xlo = xlo > xlim[0]
        xhi = xhi < xlim[1]
     endif

     xtest = findgen(ntest) / (ntest - 1) * (xhi - xlo) + xlo
     
     ;- coarse grid of xmin guesses
     ksds = fltarr(ntest)
     for i = 0, ntest - 1, 1 do begin
        temp = powerlaw_fitexp(data, xtest[i], ksd = ksd)
        if ~finite(temp) then ksd = !values.f_nan
        ksds[i] = ksd
     endfor

     ;- refine coarse grid to get best xmin and alpha
     lo = min(ksds, midloc, /nan)

     ;- occasionally, there are multiple adjacent ksd minima.
     ;- Anticipate this and bracket the minimum correctly
     loloc = midloc
     while((loloc gt 0) && (ksds[loloc] eq lo)) do loloc--
     
     hiloc = midloc
     while((hiloc lt (ntest-1)) && (ksds[hiloc] eq lo)) do hiloc++
     
;     assert, loloc le midloc && midloc le hiloc
;     assert, ksds[loloc] ge lo && ksds[hiloc] ge lo

     ;- handle the case where we didn't bracket a minimum
     ;- because we hit the boundary
     if (ksds[loloc] eq ksds[midloc]) then begin
        ;- this is fine - xmin seems to be below lowest data point
        xmin = xtest[midloc]
     endif else if (ksds[hiloc] eq ksds[midloc]) then begin
        ;- maybe something should be done here. But it suggests 
        ;- that almost all of the data is below the power law cutoff.
        ;- This probably means something is wrong (e.g. not powerlaw data)
        xmin = xtest[midloc]
     endif else begin
        xmin = powerlaw_xmin_golden(data, $
                                    xtest[loloc], $
                                    xtest[midloc], $
                                    xtest[hiloc], $
                                    tol = .05)
     endelse

     ;- use the (now determined) value of xmin to find alpha
     alpha = powerlaw_fitexp(data, xmin, ksd = ksd, sigma = dalpha, $
                             ad = ad, mad = mad, /verbose)
     
     ;- estimate error in xmin by sampling
     ;  from the data in a bootstrap fashion
     if arg_present(dxmin) then begin
        ntest = 500
        if keyword_set(verbose) then begin
           report = obj_new('looplister', ntest, 5)
           print, 'finding dxmin'
        endif

        xmins = fltarr(ntest)
        for i = 0, ntest - 1, 1 do begin
           if keyword_set(verbose) then report -> report, i
          
           rand = randomu(seed, sz) * sz
           fake_data = data[rand]
           ;- recursive call to fit power law
           powerlaw, fake_data, fake_alpha, fake_xmin, /get_xmin, $
                     robust = keyword_set(robust)
           xmins[i] = fake_xmin
        endfor
        
        if keyword_set(verbose) then begin
           obj_destroy, report
           print, 'done'
        endif
      
        dxmin = stdev(xmins)
        
     endif ;- keyword_set(dxmin)
  endif else begin              ;- keyword_set(get_xmin)
     ;- use the supplied value of xmin to determine alpha
     alpha = powerlaw_fitexp(data, xmin, ksd = ksd, sigma = dalpha, mad = mad, ad = ad)
  endelse

  if arg_present(mctest) then begin
     ntest = 2500    ;- should give p value accurate to 2 decimal places
     ksds = fltarr(ntest)
     lo_data = where(data lt xmin, lo_data_ct)
     lofrac = 1D * lo_data_ct / sz
     fake_data = fltarr(sz)
     if keyword_set(verbose) then begin
        report = obj_new('looplister',ntest, 5)
        print, 'starting mc test'
     endif

     for i = 0, ntest-1, 1 do begin
        if keyword_set(verbose) then report->report, i
        ;- synthesize data
        hilo = randomu(seed, sz)
        rand = randomu(seed, sz)
        lo = where(hilo lt lofrac, loct, complement = hi, ncomp = hict)
        if loct ne 0 then fake_data[lo] = data[lo_data[rand[lo] * lo_data_ct]]
        if hict ne 0 then fake_data[hi] = xmin * rand[hi]^(1D/(1-alpha))
        ;- recursive call to fit power law, store ks value
        powerlaw, fake_data, fake_alpha, fake_xmin, /get_xmin, $
                  ksd = fake_ksd, robust = keyword_set(robust)
        ksds[i] = fake_ksd
     endfor
     if keyword_set(verbose) then begin
        print, 'done'
        obj_destroy, report
     endif
     mctest = 1D * total(ksds gt ksd) / ntest
  endif  ;-keyword_set(mctest)
  
  return
end
