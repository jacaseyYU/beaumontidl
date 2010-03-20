pro movie36

;- create the frames for an animated gif of bubble 36

im = mrdfits('/users/cnb/harp/bubbles/reduced/N036.fits',0,h)
ast = nextast(h)

readcol, 'bubblemomentmap.txt',num,vlo, vhi
hit = where(num eq 36)

vlo = vlo[hit[0]]
vhi = vhi[hit[0]]

vlo = (-ast.crval[2] + vlo)/ast.cd[2,2] + ast.crpix[2] - 1
vhi = (-ast.crval[2] + vhi) / ast.cd[2,2] + ast.crpix[2] - 1

im = im[*,*,vhi:vlo]
im = sigrange(im, fraction = .95)
im = bytscl(im,/nan)

stop

end
