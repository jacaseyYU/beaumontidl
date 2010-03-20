function outliersimple, x, thresh = thresh
  if ~keyword_set(thresh) then thresh = 3
  med = median(x)
  mad = median( abs(x - med))
  return, abs(x - med) / mad lt thresh
end
