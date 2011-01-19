function pdf_transform, p, y, ylo, yhi, ystep

  if n_params() ne 5 then begin
     print, 'calling sequence'
     print, 'result = pdf_transform(p, y, ylo, yhi, ystep)'
     print, ' p sampled at regular intervals. y = new variable value at these intervals'
     print, ' ylo, yhi, ystep define sampling of transformed function'
     print, ' returns: p(y)'
     return, !values.f_nan
  endif

  num = n_elements(p)
  if n_elements(y) ne num then $
     message, 'p and y must have the same number of elements'

  if (ylo gt yhi) then $
     message, 'ylo must be < yhi'
  if ystep lt 0 then $
     message, 'ystep must be > 0'
  ny = ceil((yhi - ylo) / step)
  
  result = fltarr(ny)

  ms = monseq(y, ct)
  dydx = abs(deriv(y))
  times_jacobian = p * dydx
  for i = 0, ct - 1, 1 do begin
     ilo = ms[i,0] & ihi = ms[i,1]
     yra = y[ms[i,*]]
     ira = 0 > ((yra - ylo) / step) < (ny - 1)
     ind = indgen(range(ira)) + min(ira)
     abcissa = ylo + ind * step
     val = interpolate(times_jacobian[ilo:ihi], y[ilo:ihi], abcissa)

     if ira[1] gt ira[0] then val = reverse(val)
     result[min(ira) : max(ira) ] = val
  endfor

  return, result
end
     
