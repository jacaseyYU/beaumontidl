function poisson_pdf, x, lambda
  return, exp(-lambda + x * alog(lambda) - lngamma(x+1))
end


