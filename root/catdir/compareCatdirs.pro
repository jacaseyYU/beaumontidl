pro compareCatdirs

loadCatdir, 'catdir.107',m,a,s,n,image

indices = [1,2,3,4,5,6,7,8,9,10]
oldh = fltarr(10)

for i = 1, 10, 1 do begin
   good = where(a[m.ave_ref].nmeas eq i, ct)
   if ct eq 0 then continue
   oldh[i-1] = 1.0 * total(finite(m[good].mag)) / ct
endfor

loadCatdir, 'catdir.107.exp', m, a, s, n, image
newh = fltarr(10)

for i = 1, 10, 1 do begin
   good = where(a[m.ave_ref].nmeas eq i, ct)
   if ct eq 0 then continue
   newh[i-1] = 1.0 * total(finite(m[good].mag)) / ct
endfor


plot, loc, oldh, psym = 10, yra = [0, 1.1]

oplot, loc, newh, psym = 10, color=fsc_color('green')

stop

end
;conclusions
;new catdir has a much higher finite magnitude percentage. it
;increases from 60% when nmeas = 1 to about 100$ by nmeas eq 4. The
;old catdir, on the otherhand, has finite rates around 20-30%, with
;only a very gradual increase as the number of measurements
;increases. The only concern to me is the new catdir's high
;success rate when nmeas = 1. this seems bogus, but i will check
