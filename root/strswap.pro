function strswap, string, pattern, replace
  ct = n_elements(string)
  result = string
  for i = 0, ct - 1, 1 do $
     result[i] = strjoin(strsplit(string[i], pattern, /extract), replace)
  return, result
end
