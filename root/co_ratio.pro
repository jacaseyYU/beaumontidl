pro co_ratio

nstep = 20
ncol = arrgen(1d10, 1d18, nstep = nstep, /log)
co12 = fltarr(nstep)
co13 = co12
t12 = co12 & t13 = co12
for i = 0, nstep - 1, 1 do begin
   print, i
   x = radex('co.dat', 345.7960, .2, 50, 1d5, 2.73, ncol[i], 3.)
   co12[i] = x.flux_kkms
   t12[i] = x.tau
   x = radex('13co.dat', 330.588, .2, 50, 1d5, 2.73, ncol[i] / 40., 3.)
   co13[i] = x.flux_kkms
   t13[i] = x.tau
end
plot, ncol, co12 / co13, /xlog, charsize = 1.5
oplot, ncol, t12 * 40
end
