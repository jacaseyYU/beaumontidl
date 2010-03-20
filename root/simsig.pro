pro simsig
compile_opt idl2

restore, 'simpar_gen.sav'
sz = n_elements(dists)

;- calculate some observables
par = 1 / dists
par_meas = par + .002 * randomn(10, sz)
pmx = randomn(seed, sz) * 30/sqrt(2)                           ;- km / s
pmy = randomn(seed, sz) * 30/sqrt(2)                           ;- km / s
pm = sqrt(pmx^2 + pmy^2)/ (3.08d13) * 3d7 / dists*206265  ;- arcsec /yr
pm += randomn(seed, sz) * (.002 / 3D)                          ;- added noise
vapp = v + 5 * alog10(dists / 10)
v_meas = vapp - 5 * alog10(1/par_meas / 10)
sig = par_meas / .002
sig_pm = pm / (.002 / 3D)
vi = v - i
;stop
goto, histograms

set_plot, 'ps'
device, /land, /color, /encap, yoff = 9.5, /in, file='~/699_2/cmd.eps'
!p.charsize = 1.5
rand = randomu(seed, 1d4) * n_elements(v)
hisig = where(sig ge 4)
plot, (v-i)[hisig], v_meas[hisig], psym = symcat(16), symsize=.7, $
      xra = [-.5, 4], yra = [20, -2], xtit = 'V-I', ytit ='V'
oplot, (v-i)[rand], v[rand], psym = 3, $
       color = fsc_color('green')
near = where(dists lt 100)
oplot, (v-i)[near], v_meas[near], psym = symcat(16), symsize=.7, color = fsc_color('purple')
xyouts, 2.5, 0, textoidl('\pi/\sigma_\pi > 4')
xyouts, 2.5, 2, textoidl('D < 100 pc'), color = fsc_color('purple')
device,/close
set_plot,'X'
return

histograms:
print, 'histograms'
f = [  -2.48482, $
       15.6139, $
       -11.0326, $
       4.34295, $
       -0.584631]

filter = where (abs( f[0] + f[1] * $
                 vi + f[2] * vi^2 + $
                 f[3] * vi^3 + f[4] * vi^4 - v_meas ) lt 1)

;plot, loc, h, psym = 10, yra = [1, 1d6], xra = [-6, 10], /ylog
;oplot, loc, exp, color = fsc_color('orange')

binsz = .5
near = where(dists lt 100, complement = far)
mid = where(dists gt 100 and dists lt 500)
far = where(dists gt 1000)

hn = histogram(sig[near], binsize = binsz, loc = locn)
hn = [0,hn,0]
locn = [locn[0]-.2, locn, max(locn)+binsz]

hm = histogram(sig[mid], binsize = binsz, loc = locm)
hm = [0,hm,0]
locm = [locm[0]-.2, locm, max(locm)+binsz]


hf = histogram(sig[far], binsize = binsz, loc = locf)
hf = [0,hf,0]
olocf = [locf[0]-binsz, locf, max(locf)+binsz]
locf = findgen(4d3)/1d2 - 20
expf = total(hf) / sqrt(2 * !pi) * .2 * exp(-locf^2 / 2)


;- filter objects and calculate again
print, 'filter'

;- try proper motion filter
filter = where(pm gt 50 / 1d3)
sig = sig[filter]
dists = dists[filter]
near = where(dists lt 100, complement = far, nct)
mid = where(dists gt 100 and dists lt 500, mct)
far = where(dists gt 1000, fct)


if nct ne 0 then begin
   hn2 = histogram(sig[near], binsize = binsz, loc = locn2)
   hn2 = [0,hn2,0]
   locn2 = [locn2[0]-.2, locn2, max(locn2)+binsz]
endif
if mct ne 0 then begin
   hm2 = histogram(sig[mid], binsize = binsz, loc = locm2)
   hm2 = [0,hm2,0]
   locm2 = [locm2[0]-.2, locm2, max(locm2)+binsz]
endif

if fct ne 0 then begin
   hf2 = histogram(sig[far], binsize = binsz, loc = locf2)
   hf2 = [0,hf2,0]
   locf2 = [locf2[0]-binsz, locf2, max(locf2)+binsz]
endif

print, 'plot'

set_plot, 'ps'
device, file='~/699_2/simsig.50mas.pmfilter.eps',/encap,/land, yoff=9.5,/in, /color
!p.multi=[2,1,2]
!p.charsize = 1.5
!p.charthick = 2
!p.thick = 4
style = 3
color2 = 'crimson'
color3 = 'royalblue'

plot, locf, expf, psym = 0, /ylog, yra = [.5,3d6], xra =[-2, 15], xsty = 8, $
      xtit = textoidl('\pi_m/\sigma_\pi'), ytit = 'N', /ysty, $
      ymargin = [4,4]
values = [-5, 0, 5, 10, 15]
names = ['-10', '0', '10', '20', '30']
axis, xaxis = 1, xticks = 5, xtickv = values, xtickn = names, $
      xtit = textoidl('\pi_m (mas)')
print, 'p2'

if fct ne 0 then $
oplot, locf2, hf2, psym = 10, linestyle = style

oplot, locm, hm, psym = 10, color = fsc_color(color2)

if mct ne 0 then $
oplot, locm2, hm2, psym = 10, color = fsc_color(color2), linestyle = style

oplot, locn, hn, psym = 10, color = fsc_color(color3)

if nct ne 0 then $
oplot, locn2, hn2, psym = 10, color = fsc_color(color3), linestyle = style

print, 'p3'

xyouts, 6, 1d5, 'Distance > 1 kpc'
xyouts, 6, 8d3, '100 pc < Distance < 500 pc', color = fsc_color(color2)
xyouts, 6, 1d3, 'Distance < 100 pc', color = fsc_color(color3)

;plot, olocf, hf, psym = 10, xra = [2, 15], yra = [0, 20]

plot, locf, expf, psym = 0, xra = [3, 7], yra = [0, 40], $
      xtit = textoidl('\pi_m/\sigma_\pi'), ytit = 'N', /ysty, $
      ymargin = [4,4], xsty = 9, xtick_get = v

;values = [3,4,5,6,7]
names = string(fix(v * 2))
axis, xaxis = 1, xrange = (!x.crange * 2), $
      xtit = textoidl('\pi_m (mas)'), /xsty 

print, 'p4'
if fct ne 0 then $
oplot, locf2, hf2, linestyle = style, psym = 10

oplot, locm, hm, psym = 10, color = fsc_color(color2)

if mct ne 0 then $
oplot, locm2, hm2, linestyle = style, psym = 10, color = fsc_color(color2)

oplot, locn, hn, psym = 10, color = fsc_color(color3)

if nct ne 0 then $
oplot, locn2, hn2, linestyle = style, psym = 10, color = fsc_color(color3)

print, 'p5'
device,/close
set_plot,'X'
!p.multi=0
return

for i = 0, n_elements(loc) -1 , 1 do begin
   lo = loc[i]
   if loc[i] gt 10 then break
   hi = loc[i+1]
   binsize = hi - lo
   hit = where(sig gt lo and sig le hi, ct)
   if ct eq 0 then continue
   nnear = total(dists[hit] lt 100)
   nfar = total(dists[hit] ge 100)
   polyfill, [lo, lo, hi, hi, lo] - binsize / 2, [1, nfar, nfar, 1, 1], color = fsc_color('red')
   polyfill, [lo, lo, hi, hi, lo] - binsize / 2, [0, nnear, nnear, 0, 0] + nfar, color = fsc_color(color3)
endfor

end
