pro temp

m = mrdfits('/media/data/catdir.98/n0000/0148.cpm',1,h)
t = mrdfits('/media/data/catdir.98/n0000/0148.cpt',1,h)

rms = dblarr(n_elements(t)) * !values.d_nan
mag = rms
for i = 0L, n_elements(t)-1L, 1 do begin
   if ((i mod 100) eq 0) then print, i, n_elements(t)-1
   if t[i].nmeasure lt 100 then continue
   lo = t[i].off_measure
   hi = lo + t[i].nmeasure-1
   subm = m[lo:hi]
   hit = where(m.photcode / 100 eq 4, ct)
   if ct lt 100 then continue
   subm = subm[hit]
   good = outliercdf(subm[hit].d_ra, subm[hit].d_dec)
   good = where(good, ct)
   if ct lt 40 then continue
   subm = subm[good]
   rms[i] = sqrt(stdev(subm.d_ra)^2 + stdev(subm.d_dec)^2)
   mag[i] = mean(subm.mag,/nan)
endfor

save, rms, mag, file='backup.sav'

plot, mag, rms, psym = 3, xra = [12,22], yra = [0,.5]

stop

end

