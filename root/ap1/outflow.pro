pro outflow

im = mrdfits('~/harp/bubbles/reduced/N036.fits',0,h,/silent)

ast = nextast(h)

vlo = (115 - ast.crval[2]) / ast.cd[2,2] + ast.crpix[2]
vhi = (80 - ast.crval[2]) / ast.cd[2,2] + ast.crpix[2]


im = im[*,*,vlo:vhi]

sz = size(im)
for i=0, sz[3]-1, 1 do begin
    tv, im[*,*,i]
