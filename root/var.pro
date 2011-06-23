function var, data

  lib = file_which('var.so')
  if lib eq '' then $
     message, 'cannot find var.so'
  lib = lib[0]

  n = n_elements(data)
  result = 0D

  if size(data, /type) ne 5 then $
     data = double(data)

  junk = call_external(lib[0], 'variance', $
                       data, n, result, /unload)
  print, junk
  return, result
end

pro test

  data = randomu(seed, 1000000) + 1e9

  print, variance(data), var(data)

end
