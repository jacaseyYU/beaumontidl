pro c2test

  ;- how good is the normal approx when lambda is large
  lambda = 1d4
  
  nsample = 1d7
  x1 = randomn(seed, nsample) + sqrt(lambda / 2)
  x2 = randomn(seed, nsample) + sqrt(lambda / 2)
  chi2 = x1^2 + x2^2

  edf, chi2, px, py
  x = arrgen(min(px), max(px), nstep = 1d5)
  y = interpol(py, px, x)

  mean = 2 + lambda
  stdev = sqrt(2 * (2 + 2 * lambda))
  y2 = gauss_pdf((x - mean) / stdev)

  delt = (1 - y2) - (1 -y) 
  delt /= (1 - y)
  plot, x, y
  oplot, x, y2, color = fsc_color('red'), line = 2
  plot, x, delt
end
 
