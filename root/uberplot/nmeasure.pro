pro nmeasure
restore,file='explore.sav'

nobj = n_elements(t)
nu = intarr(nobj)
ng = intarr(nobj)
nr = intarr(nobj)
ni = intarr(nobj)
nz = intarr(nobj)

ru = nu * !values.f_nan
rg = ng * !values.f_nan
rr = nr * !values.f_nan
ri = ni * !values.f_nan
rz = nz * !values.f_nan

for i = 0L, nobj-1, 1 do begin
   lo = t[i].off_measure
   hi = t[i].nmeasure-1 + lo
   subm = m[lo:hi]
   nu[i] = total((subm.photcode / 100) eq 1)
   ng[i] = total((subm.photcode / 100) eq 2)
   nr[i] = total((subm.photcode / 100) eq 3)
   ni[i] = total((subm.photcode / 100) eq 4)
   nz[i] = total((subm.photcode / 100) eq 5)
   
   urms:
   hit = where((subm.photcode / 100) eq 1, ct)
   if ct lt 40 then goto, grms
   sub = subm[hit]
   good = outliercdf(sub.d_ra, sub.d_dec)
   hit = where(good, gct)
   if gct lt 10 then goto, grms
   ru[i] =sqrt( stdev(sub[hit].d_ra)^2 + stdev(sub[hit].d_dec)^2)

   grms:
   hit = where((subm.photcode / 100) eq 2, ct)
   if ct lt 40 then goto, rrms
   sub = subm[hit]
   good = outliercdf(sub.d_ra, sub.d_dec)
   hit = where(good, gct)
   if gct lt 10 then goto, rrms
   rg[i] =sqrt( stdev(sub[hit].d_ra)^2 + stdev(sub[hit].d_dec)^2)

   rrms:
   hit = where((subm.photcode / 100) eq 3, ct)
   if ct lt 40 then goto, irms
   sub = subm[hit]
   good = outliercdf(sub.d_ra, sub.d_dec)
   hit = where(good, gct)
   if gct lt 10 then goto, irms
   rr[i] =sqrt( stdev(sub[hit].d_ra)^2 + stdev(sub[hit].d_dec)^2)

   irms:
   hit = where((subm.photcode / 100) eq 4, ct)
   if ct lt 40 then goto, zrms
   sub = subm[hit]
   good = outliercdf(sub.d_ra, sub.d_dec)
   hit = where(good, gct)
   if gct lt 10 then goto, zrms
   ri[i] =sqrt( stdev(sub[hit].d_ra)^2 + stdev(sub[hit].d_dec)^2)

   zrms:
   hit = where((subm.photcode / 100) eq 5, ct)
   if ct lt 40 then continue
   sub = subm[hit]
   good = outliercdf(sub.d_ra, sub.d_dec)
   hit = where(good, gct)
   if gct lt 10 then continue
   rz[i] =sqrt( stdev(sub[hit].d_ra)^2 + stdev(sub[hit].d_dec)^2)
endfor

plot, info.imag, info.myrms, psym = 3,yra=[0,.3], xra = [10,22],/nodata
oplot, info.imag, info.myrms, psym=3
oplot, info.umag, ru, psym = 3, color = fsc_color('purple')
oplot, info.gmag, rg, psym = 3, color = fsc_color('green')
oplot, info.rmag, rr, psym = 3, color = fsc_color('red')
oplot, info.imag, ri, psym = 3, color = fsc_color('orange')
oplot, info.zmag, rz, psym = 3, color = fsc_color('chocolate')
stop
end
