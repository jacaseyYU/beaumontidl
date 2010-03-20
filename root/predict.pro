pro predict

restore, file='~/reduce.sav'
mdata = mags[1,*]

mag = [12,13,14,15,16,17,18,19,20]
rms = [1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 3, 8, 20]

m = findgen(100)/99*8+12
rm = interpol(rms, mag, m)
plot, m, rm

restore, '~/pro/simpar_gen.sav'
vapp = v + 5 * alog10(dists / 10)

nreal = 0
for i = 12, 20, 1 do begin
   hit = where(vapp gt i and vapp lt i+1, ct)
   dhit = where(mdata gt i and mdata lt i+1, dct)
   if ct eq 0 then continue
   print, ct, i, format='(i, " objects at magnitude ", i)'
   thresh = 3.5 * rms[i-12]
   print, thresh, format='("3.5 sigma limit:", f)'
   sub = dists[hit]
   near = where(sub lt 1/(thresh / 1d3), nct, ncomplement = fct)
   frac = 1d * nct / fct
   nreal += frac * dct
   print, dct, dct * frac, format='(i, " data points at this mag. ", f, " real expected")'
endfor
print, nreal, format='("Total real objects expected:", f)'
end
