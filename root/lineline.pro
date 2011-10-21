function lineline, x1, x2, y1, y2, x3, x4, y3, y4

  xnum = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
  xden = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

  x = xnum / xden

  ynum = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)
  yden = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  y = ynum / yden

  return, transpose([[x],[y]])
end


pro test_lineline
  
  x1 = 0.
  x2 = 1.
  y1 = 0.
  y2 = 1.
  x3 = 0.
  x4 = 1.
  y3 = 1.
  y4 = 0.

  assert, max(abs([0.5, 0.5] - lineline(x1, x2, y1, y2, x3, x4, y3, y4))) lt 1e-4

  print, 'All tests passed'
end
  
  

  

