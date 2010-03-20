function regionMask, header,x,y

;construct a bitmask for an image described by the fits header
;'header' and a polygon described by the vertices x and y. The output
;array equals 1 for points inside the polygon.

;header info
ast=nextast(header)
naxis1=ast.sz[0]
naxis2=ast.sz[1]
crval1=ast.crval[0]
crval2=ast.crval[1]
crpix1=ast.crpix[0]
crpix2=ast.crpix[1]
cdelt1=ast.cd[0,0]
cdelt2=ast.cd[1,1]

xind=crval1+(findgen(naxis1)+1-crpix1)*cdelt1
yind=crval2+(findgen(naxis2)+1-crpix2)*cdelt2

xind=reform(rebin(xind,naxis1,naxis2),naxis1*naxis2)
yind=reform(rebin(reform(yind,1,naxis2),naxis1,naxis2),naxis1*naxis2)

out=inside(xind,yind,x,y)
out=reform(temporary(out),naxis1,naxis2)

return,out


end
