pro cv_explore

  restore, '/media/cave/catdir.98/s0000/4801.good.sav'
  bad = where(par.parallax eq 0)
  par[bad].parallax = !values.f_nan
  ux2 = total(par.parallax^2, 1, /nan) / total(finite(par.parallax), 1)
  ux = total(par.parallax, 1, /nan) / total(finite(par.parallax), 1)
  err = sqrt(total(par.covar[4,4], 1, /nan) / total(finite(par.parallax), 1))

  off = max(abs(par.parallax - rebin(1#ux, 4, n_elements(ux))), dimen = 1)

  delta = sqrt(ux2 - ux^2)
  sig = par[0,*].parallax / sqrt(par[0,*].covar[4,4])

  good = where(off lt err)
  h1 = histogram(sig[good], loc = l1, binsize = .2)
  h2 = histogram(sig, loc = l2, binsize = .2)
  plot, l1, 1d * h1 / (total(h1) * (l1[1] - l1[0])), psym = 10
  oplot, l2, 1d * h2 / (total(h2) * (l2[1] - l2[0])), psym = 10, color = fsc_color('red')
  ind = arrgen(-10, 10, nstep = 100)
  oplot, ind, 1 / sqrt(2 * !pi) * exp(-ind^2 / 2)
end
