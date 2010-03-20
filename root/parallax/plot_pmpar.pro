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
pro plot_pmpar, ra, dec, dra, ddec, jd, fit, $
                pop = pop, included = included, $
                _extra = extra, ps = ps
compile_opt idl2

if n_params() ne 6 then begin
   print, 'calling sequence:'
   print, 'plot_pmpar, ra, dec, dra, ddec, jd, fit,'
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

winid = nopar ? 2 : 0
if ~keyword_set(ps) then window, winid, xsize = 800, ysize = 800

;-evaluate the fit
ndates = range(jd)
dates = arrgen(min(jd) - .3 * ndates, max(jd) + .3 * ndates, nstep = (n_elements(jd) > 100))
eval_pmpar, dates, fit, fit_ra, fit_dec
eval_pmpar, jd, fit, exp_ra, exp_dec ;-expected locations

;-set up plot
xcen = mean(ra)
ycen = mean(dec)

px      = (ra - xcen) * 36D5 * cos(fit.dec * !dtor)
py      = (dec - ycen) * 36D5
dpx     = dra * 36D5
dpy     = ddec * 36D5
exp_ra  = (exp_ra - xcen)   * 36D5 * cos(fit.dec * !dtor)
exp_dec = (exp_dec - ycen) * 36D5
fit_ra  = (fit_ra - xcen)   * 36D5 * cos(fit.dec * !dtor)
fit_dec = (fit_dec - ycen) * 36D5


;- guess at the range if not provided
tags = keyword_set(extra) ? tag_names(extra) : ''

range = range([minmax(fit_ra), minmax(fit_dec), minmax(px), minmax(py)])
range = (1.05 * range) * [-1,1]
xtag = where(strmatch(tags, 'XRANGE'), xhit)
ytag = where(strmatch(tags, 'YRANGE'), yhit)
xrange = xhit ? extra.(xtag) : range[[1,0]]
yrange = yhit ? extra.(ytag) :  range + .05 * range(range)


if keyword_set(ps) then begin
   set_plot, 'ps'
   filename = nopar ? ps+'.pm' : ps
   device, /color, file = filename
   !p.font = -1
endif

;- plot options
thick = 1.5

plot, [1],[1], /nodata, xra = xrange, yra = yrange, $
      charsize = charsize, /xsty, /ysty, xtit='!6East Offset (mas)', $
      ytitle = '!6North Offset (mas)', _extra = extra

;- connect lines between expected and observed
for i = 0, n_elements(exp_ra) - 1 , 1 do begin
;   if (~included[i]) then continue
   tvellipse, dpx[i], dpy[i], px[i], py[i], color = fsc_color('forestgreen'), $
              /data, thick = thick
   
                 ;   oplot, [ exp_ra[i], px[i]], $
;          [exp_dec[i], py[i]], $
;          color = fsc_color('orange'), thick = thick
endfor
oplot,  fit_ra, fit_dec, thick = thick

;if keyword_set(pop) then begin
;   for i = 0, n_elements(exp_ra) - 1, 1 do begin
;      xyouts, px[i], py[i], strtrim(pop[i],2), /data
;   endfor
;endif

sym = symcat(16)

;hit = where(included, nhit, complement = miss, ncomp = nmiss)
;if nhit ne 0 then $
;   oplot, [px[hit]], [py[hit]], psym = sym, $
;          color = fsc_color('forestgreen')

;if nmiss ne 0 then $
;   oplot, [px[miss]], [py[miss]], psym = sym, $
;          color = fsc_color('crimson')
   
;- annotate
covar = fit.covar
fmt = '(f0.1)'

ux   = string(fit.ura,        format = fmt)
dux  = string(sqrt(covar[1,1]), format=fmt)
uy   = string(fit.udec,       format=fmt)
duy  = string(sqrt(covar[3,3]),format=fmt)
if ~(nopar) then begin
   par  = string(fit.parallax,   format=fmt)
   dpar = string(sqrt(covar[4,4]), format=fmt)
endif
chi  = string(fit.chisq / fit.ndof, format=fmt)

racen = sixty(mean(fit.ra)/15.)
deccen =sixty(mean(fit.dec))

xyouts, .2, .85, texToIDL('\alpha = '+strtrim(fix(racen[0]), 2)+'^h '+$
                          strtrim(fix(racen[1]),2)+'^m '+ $
                          string(racen[2], format='(f4.1)')+'^s '), /norm, charsize=charsize
xyouts, .2, .8, texToIDL('\delta = '+strtrim(fix(deccen[0]), 2)+'\circ '+$
                          strtrim(fix(deccen[1]),2)+"' "+ $
                          string(deccen[2], format='(f4.1)')+'" '), /norm, charsize=charsize
;xyouts, .2, .75, texToIDL('\chi_r^2 = '+chi), /norm, charsize = charsize

xyouts, .5, .85, texToIDL('\mu_x = '+ux+' \pm '+dux+' mas y^{-1}'), /norm, charsize = charsize
xyouts, .5, .8,  texToIDL('\mu_y = '+uy+' \pm '+duy+' mas y^{-1}'), /norm, charsize = charsize
if ~(nopar) then $
   xyouts, .5, .75, texToIDL('\pi  = ' + par + ' \pm ' + dpar+' mas'), /norm, charsize = charsize

if keyword_set(ps) then begin
   device, /close
   set_plot, 'x'
endif

end
