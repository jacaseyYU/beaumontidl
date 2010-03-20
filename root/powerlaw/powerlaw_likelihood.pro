function powerlaw_likelihood, data = data, xmin = xmin, alpha = alpha
  return, total(alog(alpha - 1) + $
                (alpha - 1) * alog(xmin) - $
                alpha * alog(data))
end
