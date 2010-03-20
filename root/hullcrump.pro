pro test
  points = [[0,1], [1,0], [0,0], [1,1], [.5, .5]]
  points = randomn(seed, 2, 50)
  x = hullcrump(points)
end

function hullcrump, points

  x = reform(points[0,*])
  y = reform(points[1,*])
  qhull, x, y, tr, bounds = bounds

  print, bounds
  plot, points[0,*], points[1,*], psym = 4, yra = [-3,3], xra = [-3,3]
  for i = 0, n_elements(tr[0,*]) -1, 1 do begin
     oplot, [points[0,tr[0,i]], points[0, tr[1,i]]], $
            [points[1, tr[0,i]], points[1, tr[1,i]]]
  endfor
  print, tr
end
