function ln_pl_like, x, mu = mu, sigma = sigma, alpha = alpha, xc = xc, param = param

  if n_elements(param) ne 0 then begin
     mu = param[0]
     sigma = param[1]
     alpha = param[2]
     xc = param[3]
  endif
  minval = min(x, /nan)
  if minval lt 0 then return, -!values.f_inf

  ;- for x < xc:
  ;- PDF ~ LN(mu, sigma)
  ;- for x > xc:
  ;- PDF ~ lambda * (x / xc)^(-alpha - 1)
  ;- lambda = LN(xc ; mu, sigma) for continuity
  ;- need to scale both by a normalizing factor
  a = 1 / (sqrt(2 * !pi) * sigma * xc) * $
      exp( -(alog(xc)-mu)^2 / 2 * sigma^2)
  lambda = .5 * erfc((mu - alog(xc)) / sqrt(2 * sigma^2))
  lambda += xc * a / alpha
  lambda = 1. / lambda

  lo = where(x lt xc, loct, complement = hi, ncomp = hict)
  if loct ne 0 then begin
     ln = -alog(sqrt(2 * !pi * sigma^2 * x[lo]^2))
     ln += -(alog(x[lo]) - mu)^2 / (2 * sigma^2)
     ln += alog(lambda)
     ln = total(ln, /nan)
  endif else ln = 0.

  if hict ne 0 then begin
     pl = -(alpha + 1) * alog(x / xc)
     pl += alog(lambda)
     pl += alog(a)
     pl = total(pl, /nan)
  endif else pl = 0.
  return, ln + pl
end
