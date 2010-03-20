pro filtertest
restore, 'simpar_gen.sav'
sz = n_elements(dists)

;- calculate some observables
par = 1 / dists
par_meas = par + .002 * randomn(10, sz)
sig = par_meas / .002
vapp = v + 5 * alog10(dists / 10)
v_meas = vapp - 5 * alog10(1/par_meas / 10)
vi = v - i

;- fit to the nearby objects
f = [  -2.48482, $
       15.6139, $
       -11.0326, $
       4.34295, $
       -0.584631]

filter = where (abs( f[0] + f[1] * $
                 vi + f[2] * vi^2 + $
                 f[3] * vi^3 + f[4] * vi^4 - v_meas ) lt 1)

dists = dists[filter]
sig = sig[filter]
near = where(dists lt 100, complement = far)
mid = where(dists gt 100 and dists lt 500)
far = where(dists gt 1000)

binsz = .2
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

set_plot, 'ps'
device, file='~/699_2/filter.talk.eps',/encap,/land, yoff=9.5,/in, /color
!p.multi=[2,1,2]
!p.charsize = 1.5
!p.charthick = 1.5
!p.thick = 4

plot, olocf, hf, psym = 10, /ylog, yra = [.5,3d6], xra =[0, 15], /xsty, $
      xtit = textoidl('\pi/\sigma_\pi'), ytit = 'N'
oplot, locm, hm, psym = 10, color = fsc_color('blue')
oplot, locn, hn, psym = 10, color = fsc_color('green')
xyouts, 6, 10d5, 'Distance > 1 kpc'
xyouts, 6, 7d4, '100 pc < Distance < 500 pc', color = fsc_color('blue')
xyouts, 6, 1d4, 'Distance < 100 pc', color = fsc_color('green')

;plot, olocf, hf, psym = 10, xra = [2, 15], yra = [0, 20]
plot, olocf, hf, xra = [3, 7], yra = [0, 40], $
      xtit = textoidl('\pi/\sigma_\pi'), ytit = 'N', psym = 10

oplot, locm, hm, psym = 10, color = fsc_color('blue')
oplot, locn, hn, psym = 10, color = fsc_color('green')
device,/close
set_plot,'X'
!p.multi=0
return


end
