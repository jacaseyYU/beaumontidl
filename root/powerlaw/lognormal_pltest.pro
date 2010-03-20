pro lognormal_pltest

;- make sure that fitting lognormals to powerlaws gets at the global
;  - max likelihood

data = imf(random = 1d6, /muench)

lognormal_fit, data, mu, sigma, ksd = ksd, xmin = 0, /verbose

print, mu, sigma

d2 = lognormal_dist(1d6, mu = mu, sigma = sigma, xmin = 0)

mus = findgen(20) / 10 -1 + mu
sigmas = findgen(20) / 10 -1 + sigma
mus = rebin(mus, 20, 20)
sigmas = rebin(1#sigmas, 20, 20)
l = mus * 0
for i = 0, 19, 1 do begin
   for j = 0, 19, 1 do begin
      l[i,j] = lognormal_mle([mus[i,j], sigmas[i,j]], data = data, xmin = 0)
   endfor
endfor

stop

h1 = histogram(alog(data), binsize = .1, loc = l)
h2 = histogram(alog(d2), binsize = .1, loc = l2)

plot, l, h1, psym = 10, /ylog, yra = minmax([h1, h2]) > 1
oplot, l2, h2, psym = 10, color = fsc_color('red')
end
