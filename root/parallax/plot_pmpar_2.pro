;+
; PURPOSE:
;  This procedure plots the results from a proper motion / parallax
;  fit.
;
; INPUTS:
;  ra: Vector of RAs
;  dec: Vector of decs
;  dra: Error in ra
;  ddec: Error in dec
;  jd: Julian dates
;  fit: Structure encoding the fit. A pmfit or parfit structure
;
; KEYWORD PARAMETERS:
;  pop: an optional array denoting how many raw data points went into
;  each RA/DEC point (which by implication are weighted means). If
;  this keyword is present, than the values will be displayed on the
;  plot
;
;  included: An optional array of 1s/0s indicating whether each point
;  was included in the final fit. These will be plotted as green/red
;  points.
;
;  ps: Output the graph to a postscript file with a name given by the
;  value of this keyword
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;  Oct 2009: Modified calling sequence
;- 
pro plot_pmpar_2, ra, dec, dra, ddec, jd, fit, $
                pop = pop, included = included, $
                _extra = extra, ps = ps
compile_opt idl2

if n_params() ne 6 then begin
   print, 'calling sequence:'
   print, 'plot_pmpar_2, ra, dec, dra, ddec, jd, fit,'
   print, '           [pop = pop, included = included, ps = ps, _extra'
   return
endif

if ~keyword_set(included) then included = bytarr(n_elements(ra)) + 1B
good = where(included)
ra = ra[good]
dec = dec[good]
dra = dra[good]
ddec = ddec[good]
jd = jd[good]

if keyword_set(ps) then charsize = 1 else charsize = 1.5

;- make sure fit is the correct structure
name = tag_names(fit, /struct)
if name ne 'PMFIT' && name ne 'PARFIT' then $
   message, 'fit is not a PMFIT or PARFIT structure'
nopar = name eq 'PMFIT'

if ~keyword_set(ps) then window, 1, xsize = 800, ysize = 800

;-evaluate the fit
ndates = range(jd)
dates = arrgen(min(jd) - .3 * ndates, max(jd) + .3 * ndates, nstep = (n_elements(jd) > 100))
eval_pmpar, dates, fit, fit_ra, fit_dec
eval_pmpar, jd, fit, exp_ra, exp_dec ;-expected locations

;-set up plot
xcen = mean(ra)
ycen = mean(dec)
min = min(abs(ra - xcen), loc)
jd0 = mean(jd)

px      = (ra - xcen) * 36D5 * cos(fit.dec * !dtor)
py      = (dec - ycen) * 36D5
dpx     = dra * 36D5
dpy     = ddec * 36D5
exp_ra  = (exp_ra - xcen)   * 36D5 * cos(fit.dec * !dtor)
exp_dec = (exp_dec - ycen) * 36D5
fit_ra  = (fit_ra - xcen)   * 36D5 * cos(fit.dec * !dtor)
fit_dec = (fit_dec - ycen) * 36D5

;- subtract off proper motions
exp_ra -= (jd - jd0) / 365.25 * fit.ura
exp_dec -= (jd - jd0) / 365.25 * fit.dec
fit_ra -= (dates - jd0) / 365.25 * fit.ura
fit_dec -= (dates - jd0) / 365.25 * fit.udec
px -= (jd - jd0) / 365.25 * fit.ura
py -= (jd - jd0) / 365.25 * fit.udec

;- guess at the range if not provided
xstart = floor(min(dates))
tags = keyword_set(extra) ? tag_names(extra) : ''
xrange = [0, range(dates)] + 1
y1range = minmax([minmax(fit_ra),  minmax(px)])
y2range = minmax([minmax(fit_dec),  minmax(py)])
xtag = where(strmatch(tags, 'XRANGE'), xhit)
y1tag = where(strmatch(tags, 'YRANGE1'), yhit1)
y2tag = where(strmatch(tags, 'YRANGE2'), yhit2)
xrange = xhit ? extra.(xtag) : xrange
yrange1 = yhit1 ? extra.(y1tag) : y1range
yrange2 = yhit2 ? extra.(y2tag) : y2range


if keyword_set(ps) then begin
   set_plot, 'ps'
   device, /color, file = ps
   !p.font = -1
endif

;- plot options
thick = 1.5

plot, [1],[1], /nodata, xra = xrange, yra = [-100, 100], $
      charsize = charsize, /xsty, /ysty, xtit='!6JD - '+strtrim(xstart, 2), $
      ytitle = '!6East Offset (mas)', pos = [.1, .1, .95, .45]
oplot, dates - xstart, fit_ra
oploterror, jd - xstart, px, dpx * 0, dpx, psym = 4


plot, [1],[1], /nodata, xra = xrange, yra = [-100, 100], $
      charsize = charsize, /xsty, /ysty, xtit='!6JD - '+strtrim(xstart,2), $
      ytitle = '!6North Offset (mas)', _extra = extra, pos = [.1, .6D, .95, .95], /noerase
oplot, dates - xstart, fit_dec
oploterror, jd - xstart, py, py * 0, dpy, psym = 4

result = 0
for i = 0, n_elements(jd) - 1, 1 do begin
   junk= min(abs(jd[i] - dates), minloc)
   print, 'ra: ', abs(fit_ra[minloc] - px[i]) /  dpy[i]
   print, 'dec: ',abs(fit_dec[minloc] - py[i]) /  dpx[i]
   result += (fit_dec[minloc] - py[i])^2 / (dpy[i])^2 + $
             (fit_ra[minloc] - px[i])^2 /  (dpx[i])^2
   
endfor
print, result, sqrt(result / (2 * n_elements(jd)))
if keyword_set(ps) then begin
   device, /close
   set_plot, 'x'
endif

end
