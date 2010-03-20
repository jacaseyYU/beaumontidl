pro pidist

restore, '~/reduce.sav'

set_plot,'ps'
device, file='pi_t_test.eps',/encap,/color,/land,yoff=9.5,/in
!p.thick=4
!p.charsize=2
!p.charthick=2

pi = par.parallax / sqrt(par.covar[4,4])
;good = where(par.ndof gt 15)
;pi = pi[good]
h = histogram(pi, binsize = .1, loc = loc)

plot, loc, h, psym = 10, yra = [0, 3d3], xra = [-5,5]

x = findgen(1d3)/1d3 *range(loc) + min(loc)
dx = x[1] - x[0]
colors = ['blue','red','green','orange']
dof = [3, 25, 300]
for i = 0, n_elements(dof)-1, 1 do begin
   y = t_pdf(x, dof[i])
   y = y - shift(y,1)
   y[0] = 0
   y[n_elements(y)-1] = 0
   
   oplot, x, y /dx * .1 * total(h), color = fsc_color(colors[i])
endfor
oplot, x, total(h) * .1 /(sqrt(2 * !pi)) * exp(-x^2/2), $
       color = fsc_color('orange')


device,/close
set_plot,'x'
end
