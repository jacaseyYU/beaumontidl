pro nicer_test

nobj = 100

j = randomn(seed, nobj) * 15
h = randomn(seed, nobj) * 15
k = randomn(seed, nobj) * 15
i1 = randomn(seed, nobj) * 15
i2 = randomn(seed, nobj) * 15

dj = randomu(seed, nobj) * .1
dh = randomu(seed, nobj) * .1
dk = randomu(seed, nobj) * .1
di1 = randomu(seed, nobj) * .1
di2 = randomu(seed, nobj) * .1



mag = transpose([[j],[h],[k],[i1],[i2]])
dmag = transpose([[dj],[dh],[dk],[di1],[di2]])

av1 = nicer(j,dj, h, dh, k, dk, i1, di1, i2, di2)
av2 = nicer_work(mag, dmag)

if nobj eq 1 then begin
   print, av1, av2
endif else begin
plot, av1[1,*], av2[1,*], charsize = 2, psym = 3
endelse

end
