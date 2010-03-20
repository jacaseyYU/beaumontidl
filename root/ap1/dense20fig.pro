pro dense20fig

hcop=mrdfits('~/harp/bubbles/reduced/N029H.fits',0,hh,/silent)
irac=mrdfits('~/glimpse/fits/I4/29_I4.fits',0,hi,/silent)

;-regrid
ast=nextast(hi)

jcmt = postagestamp(hcop, hh, [ast.crval[0],ast.crval[1],37.],$
                    ast.cd[1,1]*[ast.sz[1],ast.sz[1],0]+[0,0,6], $
                    [ast.cd[0,0],ast.cd[1,1],.2])
jcmt=total(jcmt,3,/nan)
jcmt = jcmt[1:883,1:883]
mask=bytarr(883,883)
mask[250:380,450:600]=1
jcmt*=mask
jcmt=convolve(jcmt,psf_gaussian(npixel=50,fwhm=10,/normalize))
window,2,xsize=ast.sz[0], ysize=ast.sz[1], retain=2

im=fltarr(ast.sz[0],ast.sz[1],3)
bw = bytscl(30 > irac < 200)
im[*,*,0]=bw/2
im[*,*,1]=bw/2
im[*,*,2]=bw/2

im[*,*,0] = bw/2 + bytscl(jcmt > 2)/2


tv, im, true=3
out=tvrd(/true)
write_png,'29densefig.png',out

end
