function pdf_transform, p, y, yout

  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, 'result = pdf_transform(p, y, yout)'
     print, ' p sampled at regular intervals. y = new variable value at these intervals'
     print, ' yout: output sampling. must be monotonic'
     print, ' returns: p(y)'
     return, !values.f_nan
  endif

  num = n_elements(p)
  if n_elements(y) ne num then $
     message, 'p and y must have the same number of elements'
  
  result = yout * !values.f_nan
  ny = n_elements(yout)

  ms = monseq(y, ct)
  dydx = abs(deriv(y))
  div_j = p  / dydx

  for i = 0, ny - 2, 1 do begin

     ;- find crossing points
     cross = (y  - yout[i]) * (shift(y,-1) - yout[i]) lt 0
     cross[n_elements(cross) - 1] = 0
     hit = where(cross, xct)
     
     if xct eq 0 then continue
     frac = (yout[i] - y[hit]) / (y[hit+1] - y[hit])
     assert, max(frac) le 1 and min(frac) ge 0
     result[i] = total(div_j[hit] * (1 - frac) + div_j[hit+1] * frac, /nan)
;     if (yout[i] / 1d5 lt 2.5 and yout[i]/1d5 gt 2) then print, yout[i]/1d5, xct
  
  endfor
  return, result
end
     
pro test
  !p.multi = [0,2,1]

  ;- monotonic case
  x = findgen(11) - 5
  p = exp(abs(x))
;  p = x * 0 + 2
  y = 2 * x

  yout = arrgen(-5., 5., nstep = 60)
  pp = pdf_transform(p, y, yout)

  plot, yout, pp, psym = -4
  oplot, y, p/2, color = fsc_color('red'), psym = -4

  ;- non-monotonic (but symmetric -- makes analytic solution easy)
  y = x^2 / 5
  pp = pdf_transform(p, y, yout)
  plot, yout, pp, psym = -4
  oplot, y, p / abs(2*x/5) * 2, color = fsc_color('red'), psym = -4
  !p.multi = [0]
end
