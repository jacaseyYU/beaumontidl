pro contour_aspect_single, x, y
  
  DEBUG = 1

  ;- get normal vector for each line segment
  mx = (x + shift(x, -1))/2.
  my = (y + shift(y, -1))/2.

  dx = shift(x, -1) - x
  dy = shift(y, -1) - y

  ;- contours travel clockwise
  norm = sqrt(dx^2 + dy^2)
  dx /= norm
  dy /= norm
  dir = transpose([[dy], [-dx]])
  nx = reform(dir[0,*])
  ny = reform(dir[1,*])

  if DEBUG then begin
     plot, [x, x[0]], [y, y[0]]
     oplot, mx, my, psym = symcat(16), symsize = 1
  endif

  lengths = fltarr(n_elements(dx))
  for i = 0, n_elements(mx) - 1, 1 do begin
     ixy = lineline(mx[i], (mx+nx)[i], my[i], (my+ny)[i], $
                    x, shift(x, -1), y, shift(y, -1))
     
     ;- find nearest intersection in direction of normal
     dot = (ixy[0,*] - mx[i]) * nx[i] + (ixy[1,*] - my[i]) + ny[i]
     good = where(dot gt 0, ct)
     assert, ct ge 1
     best = min(dot[good])
     lengths[i] = best
     
     if DEBUG then begin
        oplot, [mx[i], mx[i] + nx[i] * best], $
               [my[i], my[i] + ny[i] * best], $
               color = '0000ff'xl
     endif
  endfor
  
end


pro test

  d = dist(256)
  contour, d, lev = [100], path_xy = xy, path_info = info

  x = reform(xy[0,*])
  y = reform(xy[1,*])

  
  contour_aspect_single, x, y
end
