pro reduceplots, path = path

restore, path+'.sav'
print, path, median(par.ra), median(par.dec)

;summarize_reduction, path+'.sav'
;m = mrdfits('~/catdir.98/n0000/0148.cpm',1,h)
;t = mrdfits(path+'.cpt',1,h)
title=path


ncol = n_elements(par[*,0])
nrow = n_elements(par[0,*])
row_ind = indgen(nrow) * ncol

mpar = total(par.parallax, 1) / ncol
mpar2 = total(par.parallax^2, 1) / ncol
err = sqrt(max(par.covar[4,4], dimen=1))
good = where(sqrt(mpar2 - mpar^2) lt 2 * err)
pos = pos[0, good]
par = par[0, good]

;pi = par.parallax
;top = max(pi, loc, dimen = 1)

;pos = pos[row_ind + top]
;par = par[row_ind + top]


chi = pos.chisq / pos.ndof
err = sqrt(pos.dra^2 + pos.ddec^2) * 36d5
mag = mags
parsig = par.parallax / sqrt(par.covar[4,4])
pmxsig = par.ura / sqrt(par.covar[1,1])
pmysig = par.udec / sqrt(par.covar[3,3])

plot, mag, err, psym = 3, yra = [.1,50], xra = [10,22], /ylog, $
      xtit = 'Magnitude', ytit = 'Positional error (mas)', $
      tit=path


plot, mag, chi, psym = 3, yra = [0,5], xra= [10,22], $
      xtit = 'Mag', ytit = 'Reduced Chi2', title = path

;h = histogram(chi, binsize = .1, loc = loc)

;plot, loc, h, psym = 10, $
;    xtit = 'Reduced Chi2', title = title


;h = histogram(err, binsize = 1, loc = loc)
;plot, loc, h, psym = 10, $
;    xtit = 'Positional Error', title = title, $
;      xra = [0,25]

h = histogram(parsig, loc = loc, binsize = .1, min = -10, max = 10)
plot, loc, h, psym = 10, $
      xtit = textoidl('\pi / \sigma_\pi'), title=path, xra = [-6, 6]
oplot, loc, .1 / (sqrt(2 * !pi)) * total(h) * exp(-loc^2/2), color = fsc_color('green'), thick = 2

xra = [-5,5]
yra=[0,250]
h = histogram(pmxsig, loc = loc, binsize = .1, min = -30, max = 30)
plot, loc, h, psym = 10, title=path, $
      xtit = textoidl('\mu_\alpha / \sigma'), xra = xra, /xsty
oplot, loc, .1 / (sqrt(2 * !pi)) * total(h) * exp(-loc^2/2), color = fsc_color('green'), thick = 2

h = histogram(pmysig, loc = loc, binsize = .1, min = -30, max = 30)
plot, loc, h, psym = 10, title=path,  $
      xtit = textoidl('\mu_\delta / \sigma'), xra = xra, /xsty
oplot, loc, .1 / (sqrt(2 * !pi)) * total(h) * exp(-loc^2/2), color = fsc_color('green'), thick = 2

!p.multi[0]--
end
