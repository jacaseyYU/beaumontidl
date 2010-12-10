pro error_ellipse

  npt = 10000
  theta = 20 * !dtor
  a = randomn(seed, npt) * 30
  b = randomn(seed, npt) * 5
  x = a * cos(theta) - b * sin(theta)
  y = a * sin(theta) + b * cos(theta)

  covar = cnb_covar(transpose([[x],[y]]))

  plot, x, y, psym = 3

  result = eigenql(covar, eigenvec = ev)

  print, sqrt(result)
  print, ev
  ev[*,0] *= sqrt(result[0])
  ev[*,1] *= sqrt(result[1])
  oplot, [0, ev[0,0]], [0, ev[1,0]] , color = fsc_color('red')
  oplot, [0, ev[0,1]], [0, ev[1,1]] , color = fsc_color('blue')
end
