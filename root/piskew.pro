pro piskew_driver
!p.multi=[6,2,3]
set_plot, 'ps'
device, file='~/699_2/piskew.talk.eps', /encapsulated, /color, /land, $
        yoff = 9.5, /in
piskew, 15, 6D
piskew, 20, 6D

piskew, 15, 10D
piskew, 20, 10D

piskew, 15, 14D
piskew, 20, 14D
device, /close
set_plot,'X'
end

pro piskew, mapp, pi
;- apply bayes thm to simualted par data, and the apriori distances
;  - from apriori_distance.pro

;-measurement properties
;mapp = 15
;pi = 6D ;-mas
dpi = 2D;-mas

;- values of pi
pis = findgen(1d2) / 1d2 * 25
;pis = findgen(1d2) / 1d2 * (pi + 5 * dpi)
ds = 1 / (pis / 1d3)

apriori_distance, mapp, 'v', dist, prob, distcutoff = 1d4, /noplot
;- interpolate onto pis
prob = interpol(prob, dist, ds)
lf = prob / ds^2 ;- part due to Luminosity function 
prob *= ds^2 ;- transform of variables from d to pi

likelihood = exp(-(pi - pis)^2 / (2 * dpi^2))
posterior = likelihood * prob
malm = ds^4 * (ds lt 1d4)

;- normalize
likelihood /= total(likelihood,/nan)
posterior /= total(posterior,/nan)
lf /= total(lf, /nan)
malm /= total(malm, /nan)

;-fix for thin bins
likelihood *= 10
posterior *= 10
lf *= 10
malm *= 10

top1 = max(likelihood, lloc)
top2 = max(posterior, ploc,/nan)
print, pis[lloc], pis[ploc]

r = 22;pi + 5 * dpi
l = 0
t = 2 * max(likelihood)
b = 1d-5


!p.thick = 4
!p.charthick = 2
!p.charsize = 1.5
plot, pis , posterior, xra = [l,r], yra = [b, t], /nodata, $
      xtit = textoidl('\pi (mas)'), ytit = textoidl('P(\pi)'), charsize = charsize, $
      /xsty, /ysty, /ylog

color = 'purple'
color2 = 'forestgreen'

oplot, pis, posterior, color = fsc_color('blue')
oplot, pis, likelihood, color = fsc_color('red')
oplot, pis, lf, color = fsc_color(color2)
oplot, pis, malm, color = fsc_color(color)

boxl = l + .7 * (r - l)
boxr = l + .98 * (r-l)
boxb = 1d-4
boxt = .2
polyfill, [boxl, boxr, boxr, boxl, boxl], $
          [boxb, boxb, boxt, boxt, boxb], color = fsc_color('white')
oplot, [boxl, boxr, boxr, boxl, boxl], $
          [boxb, boxb, boxt, boxt, boxb], color = fsc_color('black')

!p.charsize = .8

textl = boxl + .15 * (boxr - boxl)
pist = string(pi, format='(i2)')
mst = string(mapp, format='(i2)')
xyouts, textl, .06, textoidl('m ='+mst)
xyouts, textl, .02, textoidl('\pi_m= '+pist+' mas')
xyouts, textl, .006,  'Likelihood', color = fsc_color('red')
xyouts, textl, .002,   textoidl('\pi^{-4}'), color = fsc_color(color)
xyouts, textl, .0006, 'LF', color = fsc_color(color2)
xyouts, textl, .0002,  'Posterior', color = fsc_color('blue')



end
