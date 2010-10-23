pro h2co_grid

  ngrid = 20
  ts = arrgen(10D, 200D, nstep = ngrid)
  ns = arrgen(1d4, 1d8, nstep = ngrid, /log)
  
  h524 = fltarr(ngrid, ngrid) & h505 = h524
  f524 = 363.9459 & f505 = 362.7361

  for i = 0, ngrid-1, 1 do begin
     print, i
     for j = 0, ngrid-1, 1 do begin
        sim = radex('p-h2co.dat', 355, 20, ts[i], ns[j], 2.7, 3d13, 1.)
        lo = min(abs(sim.freq - f524), hit)
        assert, lo lt 1d-2
        h524[i,j] = sim[hit].flux_kkms

        lo = min(abs(sim.freq - f505), hit)
        assert, lo lt 1d-2
        h505[i,j] = sim[hit].flux_kkms
     endfor
  endfor        
  ratio = h524 / h505
  contour, transpose(ratio), ns, ts, /xlog, lev=arrgen(1, 10, nstep = 10), charsize= 1.5, c_lab=replicate(1, 10)
  stop
end
