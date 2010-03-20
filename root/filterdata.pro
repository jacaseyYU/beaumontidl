pro filterdata

restore, '~/reduce.sav'
mags[0,*] += 1.460
mags[1,*] += 0.978
mags[2,*] += 0.744
mags[3,*] -= 0.200

;plot, mags[0,*] - mags[1,*], mags[0,*], psym = 3, yra = [25, 10], $
;      xra = [-0.5, 3]

;return

delt = sqrt(pos.dra^2 + pos.ddec^2) * 36d5
;plot, mags[2,*], delt, psym = 3, /ylog, yra = [.5, 300], xra = [8, 22]
;oplot, [0, 30],[5,5]

;return

vi = mags[0,*] - mags[2,*]
iz = mags[2,*] - mags[3,*]

pi = par.parallax
dist = 1 / (pi / 1d3) ;- in parsec
v_meas = mags[0,*] - 5 * alog10(dist / 10)
i_meas = mags[2,*] - 5 * alog10(dist / 10)
v_meas = v_meas

dov = finite(mags[0,*])
dor = finite(mags[1,*])
doi = finite(mags[2,*])
doz = finite(mags[3,*])

sig = where(pi / sqrt(par.covar[4,4]) gt 3.5 and par.chisq / par.ndof lt 2 and dov, ct)
   

;- fit to the nearby objects
f = [  -2.48482, $
       15.6139, $
       -11.0326, $
       4.34295, $
       -0.584631]

;set_plot,'ps'
;device, file='~/699_2/cmd_data.eps',/encap,/color, yoff = 9.5, /in, /land
!p.charsize = 1.5
!p.charthick = 3
x = findgen(100)/10-5
y = f[0] + f[1]*x + f[2] * x^2 + f[3]*x^3 + f[4]*x^4
plot, vi, v_meas, psym = 3, yra = [22, -5], xra = [-2, 5], /xsty, /nodata, $
      xtit = 'V - I', ytit = 'V'
help, sig
help, where(finite(vi[sig]) and finite(v_meas[sig]))
;oplot, vi[sig], v_meas[sig], psym = symcat(16)
oplot, iz[sig], i_meas[sig], psym = symcat(16)

;oplot, x, y
xyouts, 3, 0, 'Simulation', color = fsc_color('green')
xyouts, 3, 2,textoidl('Data (\pi/\sigma_\pi > 3.5)')
restore, 'simcmd.sav'
simvi = simv - simi
;oplot, simvi, simv, color = fsc_color('green'), psym = 3
oplot, simi - simz, simz, color = fsc_color('green'), psym = 3
;stop
filter = where (abs( f[0] + f[1] * $
                 vi + f[2] * vi^2 + $
                 f[3] * vi^3 + f[4] * vi^4 - v_meas ) lt 1)

help, filter
;device, /close
;set_plot,'x'
end
