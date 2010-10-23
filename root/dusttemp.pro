pro dusttemp

  tstar = 3000
  rstar = apcon('r_sun') * 4
  dstar = apcon('pc') * .01

  rdust = .1d-4 ;- .1 micron, in cm

  freq = arrgen(1d12, 1d16, nstep = 10000, /log)
  lam = apcon('c') / freq
  beta = 1.7

  q = 1 < (2 * !pi * rdust / lam)^beta
  ein = blackbody(tstar, freq, /freq, /cgs) * !pi * rstar^2 / dstar^2 * !pi * rdust^2 * q
  plot, freq, ein, /xlog, /ylog, charsize = 2
  ein = int_tabulated(freq, ein)
  print, ein

  temps = arrgen(1, 100, nstep = 100)
  e_out = temps * 0
  for i = 0, n_elements(temps) - 1, 1 do begin
     tmp = blackbody(temps[i], freq, /freq, /cgs) * 4 * !pi * rdust^2 * 2 * !pi * q
     e_out[i] = int_tabulated(freq, tmp)
  endfor
  plot, freq, blackbody(temps[0], freq, /freq, /cgs), /xlog, /ylog
  stop
  plot, freq, blackbody(100, freq, /freq, /cgs), /xlog, /ylog
  stop
  plot, temps, e_out, charsize = 2, /ylog
  oplot, temps, temps * 0 + ein

end
  
