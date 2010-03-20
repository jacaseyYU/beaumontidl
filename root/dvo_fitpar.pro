;+
; PURPOSE:
;  This function calculates a parallax/proper motion fit to a set of
;  observations stored in DVO formatted structures.
;
; CATEGORY:
;  Pan-STARRS, DVO, astrometry, parallax
;
;  CALLING SEQUENCE:
;   result = dvo_fitpar(m,t, [status, CLIP =clip , BINSIZE = binsize, /PLOT,
;   /MC)
;
; INPUTS:
;  m: An array of .cpm entry structures, corresponding to the set of
;  measurements for a given object
;  t: A single .cpt entry structure, describing the object referenced
;  by m
;
; KEYWORD PARAMETERS:
;  PRECLIP: Clip outliers before fitting
;  POSTCLIP: Fit outliers after fitting (within pmpar)
;  BINSIZE: Set to bin measurements by dates of width binsize days
;  PLOT: Plot the parallax fit for decent fits
;  MC: Set to run and plot a MC simulation of the data, to confirm that the
;  least squares solution is sensible.
;
; OUTPUTS:
;  The fit structure from fit_pmpar
;  status: The status variable returned by fit_pmpar (1 = success)
;
;
; MODIFICATION HISTORY:
;  Marcy 2009: Written by Chris Beaumont
;-
function dvo_fitpar, m, t, status, $
                     preclip = preclip, postclip = postclip, $
                     plot = plot, mc = mc, binsize = binsize, pm = pm

if range(m.ave_ref) ne 0 then $
   message, 'measurements do not refer to a common object'

;- collect ra, dec, time
ra = t.ra + m.d_ra / 3600
dec = t.dec + m.d_dec / 3600
jd = linux2jd(m.time) ;m.time is unix seconds

;-clip outliers
if keyword_set(preclip) then begin
   good = detectoutlier(m.d_ra, m.d_dec, thresh = 3) and $
          ((m.phot_flags and 14472) eq 0)
   ;- too few good points
   if total(good) lt 5 then begin
      status = 0
      return, keyword_set(pm) ? {pmfit} : {parfit}
   endif

   jd = jd[where(good)]
   ra = ra[where(good)]
   dec = dec[where(good)]
endif

;- bin by date
if keyword_set(binsize) then begin
   bin_by_date, jd, ra, binsize, jdbin, xbin, xerr
   bin_by_date, jd, dec, binsize, jdbin2, ybin, yerr
   assert, max(abs(jdbin - jdbin2)) eq 0
endif else begin
   xbin = ra
   ybin = dec
   jdbin = jd
;   print, stdev(ra) * 36D5, stdev(dec) * 36D5
   xerr = replicate(stdev(ra), n_elements(xbin))
   yerr = replicate(stdev(dec), n_elements(xbin))
endelse

if n_elements(jdbin) lt 5 then begin
   status = 0
   return, keyword_set(pm) ? {pmfit} : {parfit}
endif

if keyword_set(pm) then begin
   fit = fit_pm(jdbin, xbin, ybin, xerr, yerr, status, clip = postclip)
endif else begin
   fit = fit_pmpar(jdbin, xbin, ybin, xerr, yerr, status, clip = postclip)
endelse

if keyword_set(plot) && status && (fit.chisq / fit.ndof) lt 1.5 &&  $
   fit.parallax gt 0 && fit.parallax gt abs(3 * sqrt(fit.covar[4,4])) $
then begin
   plot_pmpar, xbin, ybin, xerr, yerr, jdbin, fit
   window, 1
   rms = sqrt(xerr^2 + yerr^2) * 36D5
   h = histogram(rms, binsize = range(rms) / 5., loc = loc)
   plot, loc, h, psym = 10, xtit = 'Centroid Error (mas)', charsize=1.5, yra = minmax(h)+[0,1]
   stop
   if keyword_set(mc) then begin
      mc_par, jdbin, xbin, ybin, xerr, yerr, status
      stop
   endif
endif

return, fit

end



