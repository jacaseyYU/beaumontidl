function imalign, im1, h1, im2, h2

  ast = nextast(h1)
  ast2 = nextast(h2)
  nx = ast.sz[0]
  ny = ast.sz[1]
  nz = ast.sz[2]
  x = indgen(ast.sz[0])
  y = indgen(ast.sz[1])
  z = indgen(ast.sz[2])

  x = rebin(x, nx,ny)
  y = rebin(1#y, nx,ny)
 
  npix = long(nx) * ny * nz
  n2d = long(nx) * ny

  x = reform(x, n2d)
  y = reform(y, n2d)

  coords = transpose([[x],[y],[x * 0]])
  
  sky = sky2pix(h1, coords, /back)
  coords = sky2pix(h2, sky)
  x = rebin(reform(coords[0,*], nx, ny), nx, ny, nz)
  y = rebin(reform(coords[1,*], nx, ny), nx, ny, nz)
  
  vel = (z - ast.crpix[2] + 1) * ast.cd[2,2] + ast.crval[2]
  z = (vel - ast2.crval[2] + 1) / ast2.cd[2,2] + ast2.crpix[2] - 1
  z = rebin(reform(z,1,1,nz),nx,ny,nz)

  result = im2[x,y,z]
  bad = where(x lt 0 or x ge ast2.sz[0] or $
              y lt 0 or y ge ast2.sz[1] or $
              z lt 0 or y ge ast2.sz[2])
  result[bad] = 0
  return, result
end
