pro scatter_average
restore, 'rms.sav'
mag = findgen(12) + 10
rms = fltarr(12) * !values.f_nan
erms = rms
for i = 0, 11, 1 do begin
   hit = where( abs (magarr - mag[i]) lt 1, ct)
   if ct eq 0 then continue
   rms[i] = median(rmsarr[hit])
   erms[i] = stdev(myrmsarr[hit])
endfor
plot, mag, rms

end

pro scatter_plotoutliers, m
range = [-1.1,1.1]
good = detectoutlier(m.d_ra, m.d_dec, thresh = 3) and $
       ((m.phot_flags and 14472) eq 0)
hisgood = (m.db_flags and '40'xl) ne 0

gg = where(good and hisgood, ggct)
gb = where(good and (~ hisgood), gbct)
bg = where((~ good) and hisgood, bgct)
bb = where((~ good) and (~ hisgood), bbct)

plot, [-1,1],[-1,1], /nodata

if ggct ne 0 then $
   oplot, m[gg].d_ra, m[gg].d_dec, psym = symcat(16), color = fsc_color('green')
if gbct ne 0 then $
   oplot, m[gb].d_ra, m[gb].d_dec, psym = symcat(16), color = fsc_color('purple')
if bgct ne 0 then $
   oplot, m[bg].d_ra, m[bg].d_dec, psym = symcat(16), color = fsc_color('orange')
if bbct ne 0 then $
   oplot, m[bb].d_ra, m[bb].d_dec, psym = symcat(16), color = fsc_color('red')

xyouts, .8, .9, "Chris good ipp good", color = fsc_color('green'), /norm, charsize = 1.5
xyouts, .8, .8, "Chris good ipp bad", color = fsc_color('purple'), /norm, charsize = 1.5
xyouts, .8, .7, "Chris bad ipp good", color = fsc_color('orange'), /norm, charsize = 1.5
xyouts, .8, .6, "Chris bad ipp bad", color = fsc_color('red'), /norm, charsize = 1.5

stop
end

pro scatter

;loadcatdir, '/media/cave/catdir.98', m, t, s, n, image
;m = mrdfits('catdir.98.test/n0000/0148.cpm',1,h)
;t = mrdfits('catdir.98.test/n0000/0148.cpt',1,h)
;p = mrdfits('catdir.98.test/Photcodes.dat',1,h)
path = '/media/data/catdir.98/'
ts = file_search(path+'*/*.cpt', count = ct)
ms = file_search(path+'*/*.cpm', count = mct)
assert, mct eq ct
mag = obj_new('stack')
rms = obj_new('stack')
myrms = obj_new('stack')
parallax = obj_new('stack')

pentry = {pentry, catalog:0L, object: 0L, status : -1, parallax : ptr_new()}

;- loop over catalogs
for i = 0, ct-1, 1 do begin
   t = mrdfits(ts[i], 1,h,/silent)
   
   ;-objects with too few measurements are have t.flags=1
   good = where(t.nmeasure gt 50, gct)
   if gct eq 0 then continue

   t     = t[good]
   rms->push, (sqrt(t.ra_err^2 + t.dec_err^2))
   ;myrms = rms * 0
   ;mag   = rms * 0

   lister = obj_new('looplister', n_elements(t)-1, 30)
   ;- loop over measurements
   for j = 0L, n_elements(t)-1, 1 do begin
      lister->report, j
      m = mrdfits(ms[i],1,h, $
                  range= t[j].off_measure +[0, t[j].nmeasure - 1], $
                  /silent)
      assert, range(m.ave_ref) eq 0
      ;print, t[j].ra_err, t[j].dec_err
      summary = analyze_measurements(t[j],m)
      myrms->push, (summary.myrms)
      mag->push, (summary.mag)
      if summary.myrms gt .035 then begin
         parallax->push,pentry
         continue
      endif
         
      fit=dvo_fitpar(m, t[j], status, /preclip,/plot);, binsize = 60)
      entry = {pentry, catalog : i, object : good[j], status : status, parallax : ptr_new(fit)}
      parallax->push, (entry)
;      if abs(summary.myrms - summary.rms) gt .05 && summary.myrms lt .05 then $
;         scatter_plotoutliers, m
   endfor
   obj_destroy,lister
                                ;plot, myrms, rms, psym = 4
;   plot, mag, myrms, psym = 3, yra = [0, .3], xra = [10,20]
   ;oplot, [10,20],[.02,.02],color=fsc_color('orange')
;stop
endfor

magarr = mag->toArray()
rmsarr = rms->toArray()
myrmsarr = myrms->toArray()
parallaxarr = parallax->toArray()

obj_destroy, mag
obj_destroy, rms
obj_destroy, myrms
obj_destroy, parallax

save, magarr, rmsarr, myrmsarr, parallaxarr, file = 'rms.sav'

plot, magarr, myrmsarr, psym = 3, xra = [10, 22], yra = [0, .5]
oplot, magarr, rmsarr, psym = 3, colo = fsc_color('green')
return


end
