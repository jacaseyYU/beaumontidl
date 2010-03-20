function smoothpdf, data, x, n = n, debug = debug

  if ~keyword_set(n) then n = 10
  sz = n_elements(data)
  nx = n_elements(x)

  h = histogram(data, nbins = sz / n, loc = loc, reverse = ri, omin = lo)
  binsz = loc[1] - loc[0]
  nbins = n_elements(h)

  result = x * 0

  for i = 0, nx - 1, 1 do begin
     ;- find which histogram bins we need to 'scoop up'
     ;- to collect the nearest n data points
     bin = 0 > floor(((x[i] - lo) / binsz)) < (nbins - 1)
     assert, bin eq 0 || bin eq nbins-1 || abs(loc[bin] - x[i]) lt 1.5 * binsz
     delt = 0
     while total(h[ (bin - delt - 1) > 0 : (bin + delt) < (nbins - 1)]) le n do delt++
     delt+=2
     inds = ri[ri[(bin - delt - 1) > 0] : ri[(bin + delt) < (nbins - 1) + 1]-1]
     subdata = data[inds]
     dist = abs(subdata - x[i])
     close = sort(dist)
     
     if keyword_set(debug) then begin
     ;- slow checking
        d2 = abs(data - x[i])
        s = sort(d2)
        assert, d2[s[n-1]] eq dist[close[n-1]]
     endif

     far = dist[close[n-1]]
     result[i] = n / far
  endfor

  return, result
end
     
