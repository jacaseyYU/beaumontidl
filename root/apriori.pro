pro test
;- compare dist for M,par with and without malmquist bias correction
dist = 20D
pi = 1 / dist
dpi = pi / 5
mag = 15
mapp = mag + 5 * alog10(dist / 10)
dm = .12

ngrid = 1d3
mabs = (findgen(ngrid)/ngrid - .5) * 4.5 + mag
print, minmax(mabs)
print, mag
dist = (findgen(ngrid)/ngrid)*3/pi+.3

mgrid = rebin(mabs, ngrid, ngrid)
dgrid = rebin(1#dist, ngrid, ngrid)
mappgrid = mgrid + 5 * alog10(dgrid / 10)

naive = exp(-(mappgrid - mapp)^2 / (2 * dm^2)) * $
        exp(-(1/dgrid - pi)^2 / (2 * dpi^2)) / dgrid^2

bayes = naive * apriori_eval(mgrid, dgrid)
malm = naive * apriori_eval(mgrid, dgrid,/flat)

l1 = siglevel(naive, .95)
l2 = siglevel(naive, .9)
l3 = siglevel(naive, .999)
print, minmax(naive,/nan), minmax(mgrid), minmax(dgrid)
contour, naive, mgrid, dgrid, $
         levels = [l3, l1, l2]

l1 = siglevel(malm, .95)
l2 = siglevel(malm, .9)
l3 = siglevel(malm, .999)

contour, malm, mgrid, dgrid, levels = [l3, l1, l2], $
         /over, color = fsc_color('orange')


l1 = siglevel(bayes, .95)
l2 = siglevel(bayes, .9)
l3 = siglevel(bayes, .999)

contour, bayes, mgrid, dgrid, levels = [l3, l1, l2], $
         /over, color = fsc_color('green')
end
 
function apriori_eval, M, d, flat = flat
  if keyword_set(flat) then return, d^2
  ;-assumptions:
  ;- Tsf = 1d10 yrs
  ;- L~ M^3.5
  mass = ml(M, deriv = deriv)
  sf = 1D < mass^(-2.5)
  result = imf(mass) * SF * d^2 * abs(deriv)
  bad = where(~finite(result), ct)
  if ct ne 0 then result[bad] = 0
  return, result
end
pro apriori

  ndist = 100
  nmag = 100
  dist = findgen(ndist) / (ndist) * 500 + .001
  M = findgen(nmag) / nmag * 50 + .001
  
  dist = rebin(dist, ndist, nmag)
  M = rebin(1#M, ndist, nmag)
  grid = apriori_eval(M,dist)
  grid /= max(grid,/nan)
  contour, grid, dist, M, level=[0,.2,.4,.6,.8], yra = [0,4]
end
