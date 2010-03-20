;- get apriori distribution of mags, parallaxes
pro magpidist

;- get luminosity function
restore, '~/pro/lumfunci.sav' ;- mv, phi
      
;- mapp fixed
mapp = 15
distcut = 1d2

mags = mv
dist = 10^((mapp - mags)/5) * 10
prob = phi / dist
prob2 = phi * dist * (dist lt 1d6)
plot, dist, (dist * prob2) / max(dist * prob2), /xlog, charsize = 2, $
      xtit = 'Dist (pc)', ytit = 'P(d) * d', psym = 10, $
      xra = [1d-2, 1d5], /xsty
oplot, dist, (dist * prob) / (max(dist * prob)), psym = 10, color = fsc_color('green')

pdf = dist * prob2
sub = where(dist lt distcut)
print, total(pdf[sub]) / total(pdf)
return

end
