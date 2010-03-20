function func, point, datax = datax, datay = datay, _extra = extra
  return, -1 * total(-alog(abs(point[1])) - alog(abs(point[3])) - $
                           (datax - point[0])^2 / (2 * point[1]^2) - $
                           (datay - point[2])^2 / (2 * point[3]^2))
end

pro multimin_test

tstart = systime(/seconds)
for i = 0, 1d2, 1 do begin
  ;- generate some data from a 2d gaussian
  ux = 1
  uy = 3
  sx = .5
  sy = 2
  ndata = 1d1
  datax = (randomn(seed, ndata)) * sx + ux
  datay = (randomn(seed, ndata)) * sy + uy

  ;- minimize it
  point = [ux, sx, uy, sy] + randomn(seed, 4) * .2
  min = multimin('func', point, fmin = fmin, datax = datax, datay = datay, $
                tol = 1d-4, verbose = 1)
;  print, fmin
;  print, min
;  print, [ux, sx, uy, sy]
;  print, func([ux, sx, uy, sy], datax = datax, datay = datay)
endfor

print, (systime(/seconds) - tstart) / 100
end
