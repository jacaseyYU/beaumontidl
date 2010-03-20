;+
; NAME:
;  astrocheck
;
; DESCRIPTION:
;  This procedure investigates the nature of the errors in
;  catdir.107. For each object with multiple measurements, it records
;  the error on the average ra in three different ways:
;    1) as listed in the ra_err column of the catdir table
;    2) the weighted error from the weighted mean (weights = cerr from
;       the detection's parent image
;    3) the error from the unweighted mean (error = stdev(delt_ra) /
;       sqrt(nmeas))
;
; CONCLUSIONS:
;  The scatter value found in the .cpt fits files is the rms (not the
;  sample standard deviation).
;-

pro astrocheck
compile_opt idl2

;- read the images

av = mrdfits('catdir.107/n0000/0350.cpt',1,h,/silent) ;averages
me = mrdfits('catdir.107/n0000/0350.cpm',1,h,/silent) ;measurements
im = mrdfits('catdir.107/Images.dat', 1, h, /silent)  ;raw image info

;- calculate the errors

num = n_elements(av)
err = fltarr(num)
mean = fltarr(num)
rawmean = fltarr(num)
rawerr = fltarr(num)
hit = fltarr(num)

for i = 0L, num - 1, 1 do begin
    if av[i].nmeas eq 1 then continue
    hit[i] = 1
    ind = av[i].offset + findgen(av[i].nmeas)
    values = me[ind].d_ra
    weights = im[me[ind].image_id].cerror / 50.
    mean[i] = total(values / weights^2) / total(1 / weights^2)
    rawmean[i] = mean(values)
    rawerr[i] = stdev(values) / sqrt(n_elements(ind))
;-    rawerr[i] = sqrt(mean(values^2.0))
    err[i] = sqrt( 1 / total(1 / weights^2))
endfor

;- Plot the results

good = where(hit)
sort = sort(av[good].ra_err)

set_plot, 'ps'
device, file='astrocheck.ps',/color, xsize = 7.5, ysize = 9, yoff = 1, /inches

!p.multi = [0, 1, 2]
h1 = histogram(err[good], loc = l1, binsize = .01)
h2 = histogram(rawerr[good], loc = l2, binsize = .01)
h3 = histogram(av[good].ra_err, loc = l3, binsize = .01)

avcol = fsc_color('forest green')
wcol = fsc_color('purple')
ucol = fsc_color('crimson')

plot, findgen(3), xra = [0, .2], yra = [0, 175] , /nodata, $
  xtitle = 'RA scatter (arcsec)', ytitle = 'N', charsize = 1.5
oplot, l1, h1, psym = 10, color = wcol
oplot, l2, h2, psym = 10, color = ucol
oplot, l3, h3, psym = 10, color = avcol 

xyouts, .10, 140, 'Weighted error', color = wcol, charsize = 2, /data
xyouts, .10, 120, 'Empirical error', color = ucol, charsize = 2, /data
xyouts, .10, 100, 'Catalog error', color = avcol, charsize = 2, /data

plot, [0, n_elements(av[good])], [0, .2], /nodata, $
  xtitle = 'Object Number', ytitle='RA scatter (arcsec)', charsize = 1.5
oplot, (av[good].ra_err)[sort], color = avcol
oplot, (err[good])[sort], color = wcol, psym = 4
oplot, (rawerr[good])[sort], color = ucol, psym = 4

device,/close
set_plot,'X'
!p.multi = 0
end
