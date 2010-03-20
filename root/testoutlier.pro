pro testoutlier, xs

;- make a cdf
sz = n_elements(xs)
x = xs[sort(xs)]
cdf = findgen(sz)/(sz-1)

plot, x, cdf, xra = minmax(x), yra = [-0.05, 1.05]

outcdf = outliercdf(x, status)
outmed = outliersimple(x)

good = where(outcdf, gct, complement = bad, ncom= bct)
if gct ne 0 then oplot, x[good], cdf[good], color = fsc_color('green'), psym = 4
if bct ne 0 then oplot, x[bad], cdf[bad], color = fsc_color('red'), psym = 4

good = where(outmed, gct, complement = bad, ncom= bct)
if gct ne 0 then oplot, x[good], cdf[good], color = fsc_color('green'), psym = 4, symsize = 2
if bct ne 0 then oplot, x[bad], cdf[bad], color = fsc_color('red'), psym = 4, symsize = 2
end
