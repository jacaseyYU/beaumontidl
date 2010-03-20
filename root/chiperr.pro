pro chiperr

t = mrdfits('~/catdir.98/n0000/0148.cpt',1,h)
m = mrdfits('~/catdir.98/n0000/0148.cpm',1,h)

jd = linux2jd(m.time)
jd = jd - min(jd)
jd = long(jd)
h = histogram(jd, binsize = 1, loc = loc)

top = max(h, pos)
hit = where(jd eq loc[pos])
subm = m[hit]
subm = subm[where((subm.photcode / 100) eq 4)]

err = sqrt(subm.d_ra^2 + subm.d_dec^2)
plot, subm.mag, err

stop

end
