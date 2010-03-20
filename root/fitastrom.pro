pro fitastrom, m, dra, ddec, verbose = verbose

if n_params() ne 3 then begin
   print, 'fitastrom calling sequence'
   print, 'fitastrom, m, dra, ddec, [/verbose]'
endif

;assert, max(abs(t[m.ave_ref].obj_id - m.obj_id)) eq 0
assert, range(m.image_id) eq 0 ;- only looking at 1 chip

;-refine measurements
cut1 = sqrt(m.d_ra^2 + m.d_dec^2) lt .75
cut2 = (m.phot_flags and 14472) eq 0
cut3 = finite(m.mag) and finite(m.mag_err)
good = where(cut1 and cut2 and cut3, nobj)

if nobj le 100 and keyword_set(verbose) then begin
   print, 'Too few sources ( '+strtrim(ct,2)+'). Aborting'
   return
endif

errors = m.mag_err
sigma = [100, 50, 25, 15, 10, 5]
nobj = n_elements(m)
subm = m[good]
nsub = n_elements(subm)

xgrid = rebin(m.x_ccd, nobj, nsub)
ygrid = rebin(m.y_ccd, nobj, nsub)
subxgrid = rebin(1#(subm.x_ccd), nobj, nsub)
subygrid = rebin(1#(subm.y_ccd), nobj, nsub)

subdx = rebin(1#(subm.d_ra), nobj, nsub)
subdy = rebin(1#(subm.d_dec), nobj, nsub)

d2 = (1D * xgrid - subxgrid)^2 + (1D * ygrid - subygrid)^2
assert, max(abs(d2[good, indgen(nsub)])) lt 1
d2[good,indgen(nsub)] = 999
;d2 = d2 > 3
errors = rebin(errors, nobj, nsub)

for i = 0, n_elements(sigma) - 1, 1 do begin
   ;wt = exp(- d2 / (sigma[i]^2)) / errors^2 * (d2 lt sigma[i]) 
   wt = 1D * (d2 lt sigma[i]^2) / errors^2
   xmean = total(wt * subdx, 2,/nan) / total(wt, 2,/nan)
   ymean = total(wt * subdy, 2,/nan) / total(wt, 2,/nan)
   x2 = total(wt * subdx^2, 2,/nan) / total(wt, 2,/nan)
   y2 = total(wt * subdy^2, 2,/nan) / total(wt, 2,/nan)
   
   dx = sqrt(x2 - xmean^2);1 / total(wt, 2, /nan)
   dy = sqrt(y2 - ymean^2);1 / total(wt, 2, /nan)
;   assert, (n_elements(xmean) eq nobj) and (n_elements(ymean) eq nobj) and $
;           (n_elements(dx) eq nobj) and (n_elements(dy) eq nobj)
   ;-only apply changes which are 3 sigma significant
   assert, n_elements(dx) eq nobj
   xgood = (abs(xmean) / dx) gt 3
   ygood = (abs(ymean) / dy) gt 3
   plotvec, m.x_ccd, m.y_ccd, m.d_ra * 200, m.d_dec * 200, psym = 4
   plotvec, m.x_ccd, m.y_ccd, xmean * 200 * xgood, ymean * 200 * ygood, $ 
               psym = 4, linecolor = fsc_color('blue'), linethick = 2, /over
   stop
   
xsig = where(abs(xmean) / dx gt 3, xct)
   if xct ne 0 then begin
      m[xsig].d_ra -= xmean[xsig]
   endif

   ysig = where(abs(ymean) / dy gt 3, yct)
   if yct ne 0 then begin
      m[ysig].d_dec -= ymean[ysig]
   endif

   subm = m[good]
   subdx = rebin(1#(subm.d_ra), nobj, nsub)
   subdy = rebin(1#(subm.d_dec), nobj, nsub)

endfor

dra = m.d_ra
ddec = m.d_dec

end
