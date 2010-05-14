pro powerlaw_test

;data = powerlaw_fakegen()
;- 2.5, 5.2

readcol, 'powerlaw_data.dat', id, mass, r, rho, comment='#'

data = mass

t0 = systime(/seconds)
powerlaw, data, alpha, xmin, /get_xmin, $
          dalpha = dalpha, $
          dxmin = dxmin, $
          ksd = ksprob, $
          mctest = mctest, $
          /verbose, /robust

print, alpha, dalpha, xmin, dxmin, ksprob;, mctest

print, systime(/seconds) - t0

t0 = systime(/seconds)
powerlaw, data, alpha, xmin, /get_xmin, $
          dalpha = dalpha, $
          dxmin = dxmin, $
          ksd = ksprob, $
          mctest = mctest, $
          /verbose
print, alpha, dalpha, xmin, dxmin, ksprob ;, mctest
print, systime(/seconds) - t0

end
