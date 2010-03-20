function test_sin, x, _extra = extra
  return, sin(x)
end

function test_poly, x, _extra = extra
  return, 4*x + 10*x^2 - 3*x^3 + 5
end

function test_phi, x, phi = phi,  _extra = extra
  if n_elements(phi) eq 0 then phi = 0
  return, sin(x - phi)
end

function test_nomin, x, _extra = extra
  return, 3 * x
end

function test_parabola, x, _extra = extra
  return, 4 * x^2 +  5 * x + 3
end

pro summarize, name, ax, bx, cx, fa, fb, fc, _extra = extra
  print, 'bracket for ' + name + ': '
  print, ax, bx, cx
  print, 'function values: '
  print, fa, fb, fc
  if ~finite(ax) then return
  
  xs = findgen(30) / 29 * (cx - ax) + ax
  ys = call_function(name, xs, _extra = extra)
  plot, [ax, bx, cx], [fa, fb, fc], psym = -symcat(16), $
        yra = minmax(ys)
  oplot, xs, ys, color = fsc_color('red')
end  

pro brent_test

  bracket, 'test_sin', 0, .5, ax, bx, cx, fa, fb, fc
  summarize, 'test_sin', ax, bx, cx, fa, fb, fc
  xmin = brent('test_sin', ax, bx, cx, fa, fb, fc, $
               tol = 1d-7, fmin = fmin, /verbose)
  print, xmin + !dpi / 2D
  oplot, [xmin], [fmin], psym = 8
return

;  bracket, 'test_parabola', 0, .5, ax, bx, cx, fa, fb, fc
;  summarize, 'test_parabola', ax, bx, cx, fa, fb, fc
;  xmin = brent('test_parabola', ax, bx, cx, fa, fb, fc, $
;               tol = 1d-5, fmin = fmin, /verbose)
;  oplot, [xmin], [fmin], psym = 8
  
;  return

  bracket, 'test_poly', 0, .5, ax, bx, cx, fa, fb, fc
  summarize, 'test_poly', ax, bx, cx, fa, fb, fc
  xmin = brent('test_poly', ax, bx, cx, fa, fb, fc, $
               tol = 1d-3, fmin = fmin, /verbose)
  oplot, [xmin], [fmin], psym = 8
  return
  stop

  bracket, 'test_nomin', 0, .5, ax, bx, cx, fa, fb, fc, /verbose
  summarize, 'test_nomin', ax, bx, cx, fa, fb, fc
  stop

  bracket, 'test_phi', 0, .5, ax, bx, cx, fa, fb, fc, /verbose
  summarize, 'test_phi', ax, bx, cx, fa, fb, fc
  stop

  bracket, 'test_phi', 0, .5, ax, bx, cx, fa, fb, fc, /verbose, phi = .3
  summarize, 'test_phi', ax, bx, cx, fa, fb, fc, phi = .3
  stop

end
