function test_gaussian, x, _extra = extra
return, gauss_pdf(x)
end

function test_constant, x, val = val, _extra = extra
  if ~keyword_set(val) then return, 1 else return, val
end

pro edf_stats_test

  ;- normal operation
  data = randomn(seed, 1d4)
  ksone, data, 'test_gaussian', ksd
  ksd2 = edf_stats(data, 'test_gaussian', /ks)
  print, ksd, ksd2

  ;- small data
  data = [1,2, 3]
  ksone, data, 'test_gaussian', ksd
  ksd2 = edf_stats(data, 'test_gaussian', /ks)
  print, ksd, ksd2

  ;- keyword passing happens correctly
  data = randomn(seed, 1d3)
  ksone, data, 'test_constant', ksd, val = 4
  ksd2 = edf_stats(data, 'test_constant', /ks, val = 4)
  print, ksd, ksd2

  data = randomn(seed, 1d3)
  ksone, data, 'test_constant', ksd
  ksd2 = edf_stats(data, 'test_constant', /ks)
  print, ksd, ksd2

  ;- difference between ks and ad
  data = randomn(seed, 1d3)
  ksd = edf_stats(data, 'test_gaussian', /ks)
  ad  = edf_stats(data, 'test_gaussian', /ad)
  print, ksd, ad


end
