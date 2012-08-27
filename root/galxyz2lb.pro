pro galxyz2lb, x, y, z, l, b

  xsun = 0D
  ysun = 8500D
  zsun = 30D

  phisun = atan(zsun, ysun)

  dx = x - xsun
  dy = y - ysun
  dr = sqrt(dx^2 + dy^2)
  dz = z - zsun
  dd = sqrt(dx^2 + dy^2 + dz^2)


  theta = atan(dy, dx)         ;- theta=0 is x axis
  theta -= 3 * !pi / 2          ;- gal cen = 0
  theta = wrap(theta, 2 * !pi)

  dsun_pt = dr
  b = atan(dz, dsun_pt) * !radeg
  phi0 = atan(dz, dsun_pt)
  phi1 = atan(-zsun, ysun)

  l = theta * !radeg
  b = (phi0 - phi1) * !radeg

  print, minmax(l, /nan)
  print, minmax(b, /nan)

end
