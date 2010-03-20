pro histopar

restore, '~/reduce.sav'

pi = par.parallax / sqrt(par.covar[4,4])
!p.multi = [0,1,2]
;!p.charsize = 1.5
;!p.charthick = 3
;!p.thick = 3
;set_plot,'ps'
;device, /encap, /color, /land, yoff = 9.5, /in, file='~/699_2/piall.eps'
h = histogram(pi, binsize = .1, loc = loc)
plot, loc, h, psym = 10, yra = [0, 3000], /ysty, xra = [-5,5], $
      xtit = textoidl('\pi/\sigma_\pi')
oplot, loc, .1 * total(h) / sqrt(2 * !pi) * exp(-loc^2/2), color = fsc_color('green')
!p.multi = 0
;device,/close
;set_plot,'X'
end
