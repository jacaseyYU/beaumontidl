function powerlaw_cdf, x, alpha = alpha, xmin = xmin, $
                       _extra = extra
  return, 1 - (x / xmin)^(-alpha + 1)
end

  
