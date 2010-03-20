pro showfit, path, objid, bin = bin, _extra = extra, $
             nopar = nopar

m = path+'.cpm'
t = path+'.cpt'
restore, path+(keyword_set(bin) ? '.bin.sav' : '.sav')

t = mrdfits(t, range=[objid, objid], 1, h)
lo = t.off_measure
hi = t.nmeasure + lo - 1
m = mrdfits(m, range=[lo, hi], 1, h)

good = where(flags[lo:hi] eq 0, gct)
if gct eq 0 then begin
   print, 'No good measurements for this object'
   print, flags[lo:hi], format='(Z)'
   return
endif

ra = t.ra + m[good].d_ra / 3600
dec = t.dec + m[good].d_dec / 3600

floor = .0149666
dra = sqrt((floor / 3600)^2 + (m[good].x_ccd_err  * .187 / 36d4)^2)
ddec = sqrt((floor / 3600)^2 + (m[good].y_ccd_err * .187 / 36d4)^2)

jd = linux2jd(m[good].time)

mag = median(m.mag)
title = string(mag, format='(f4.1)')

fit = keyword_set(nopar) ? pm[objid] : par[objid]

;- its cleanest just to recalculate the fit based on what was done in reduce
;- 45 day binning, clip = 3

if keyword_set(bin) then begin
;- binning
   bin_by_date, jd, ra, dra, 45, jdbin, rabin, rabinerr, pop, /noweight
   ra = rabin
   dra = rabinerr
   bin_by_date, jd, dec, ddec, 45, jdbin, decbin, decbinerr, pop, /noweight
   jd = jdbin
   dec = decbin
   ddec = decbinerr
endif

if keyword_set(nopar) then begin
   fit = fit_pm(jd, ra, dec, dra, ddec, status, $
                included = included, clip = 3, /verbose)
endif else begin
   fit = fit_pmpar(jd, ra, dec, dra, ddec, status, $
                   included = included, clip = 3, /verbose)
endelse

if (status eq 0) then begin
   print, 'Fitting astrometry failed!'
   return
endif

print, total(included)
plot_pmpar, ra, dec, dra, ddec, jd, fit, $
            pop = pop, _extra = extra, title = title, $
            nopar = nopar, included = included

if keyword_set(nopar) then fit = pm[objid] else fit=par[objid]
print, fit.ura
print, fit.udec
if ~keyword_set(nopar) then print, fit.parallax
print, fit.chisq
print, fit.ndof
print, fit.chisq / fit.ndof
end
