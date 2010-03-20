pro cmintest

mu = alog(.079 * 6.7)
sigma = .69
xmin = .5

data = lognormal_dist(1d4, mu = mu, sigma = sigma, xmin = xmin)

p0 = [mu, sigma]

nan = !values.f_nan
lobound = [nan, 0]
hibound = [nan, nan]

answer = constrained_min('lognormal_mle', p0, data = data, lobound = lobound, hibound = hibound, xmin = xmin)
print, answer
print, p0
print, [mu, sigma]
end
