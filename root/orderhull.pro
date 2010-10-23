function orderhull, points, hull, area = area, perim = perim

  nvert = n_elements(hull[0,*])
  ind = 0
  result = replicate(points[0], 2, nvert+1)
  perim = 0
  for i = 0, nvert-1, 1 do begin
     result[*,i] = points[*, hull[0,ind]]
     newind = where(hull[0, *] eq hull[1,ind], ct)
     assert, ct eq 1
     ind = newind[0]
     if i ne 0 then perim += sqrt(total((result[*,i-1] - result[*,i])^2))
  endfor
  result[*,nvert] = points[*,hull[0,ind]]
  area = poly_area(result[0,*], result[1,*])
  perim += sqrt(total((result[*,nvert-1] - result[*,nvert])^2))
  return, result
end


pro test

  x = randomn(seed, 60)
  y = randomn(seed, 60)
  pts = randomn(seed, 2, 60)
  qhull, pts, verts, bound = bound
  
  help, verts, bound
  plot, pts[0,*], pts[1,*], psym = 4
  p2 = orderhull(pts, verts)
  oplot, p2[0,*], p2[1,*]
end
