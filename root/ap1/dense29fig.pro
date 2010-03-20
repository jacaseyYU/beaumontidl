pro dense29fig

hcop=mrdfits('~/harp/bubbles/reduced/N029H.fits',0,hh,/silent)
co = mrdfits('~/harp/bubbles/reduced/N029.fits',0,hh2,/silent)
irac=mrdfits('~/glimpse/fits/I4/29_I4.fits',0,hi,/silent)

;-regrid
ast=nextast(hi)

jcmt = postagestamp(hcop, hh, [ast.crval[0],ast.crval[1],37.],$
                    ast.cd[1,1]*[ast.sz[1],ast.sz[1],0]+[0,0,6], $
                    [ast.cd[0,0],ast.cd[1,1],.2])

jcmt2= postagestamp(co, hh2, [ast.crval[0],ast.crval[1],37.],$
                    ast.cd[1,1]*[ast.sz[1],ast.sz[1],0]+[0,0,10], $
                    [ast.cd[0,0],ast.cd[1,1],.2])
mask=bytarr(883, 883)
mask[200:700, 200:700]=1
mask=rot(mask, -40)

jcmt=total(jcmt,3,/nan)
co=total(jcmt2,3,/nan)

jcmt = jcmt[1:883,1:883]
co= co[1:883, 1:883]
co *= mask
mask=bytarr(883,883)
mask[250:380,450:600]=1
jcmt*=mask
jcmt=convolve(jcmt,psf_gaussian(npixel=50,fwhm=10,/normalize))
co = convolve(co, psf_gaussian(npixel=20, fwhm = 6, /normalize))
window,2,xsize=ast.sz[0], ysize=ast.sz[1], retain=2

im=fltarr(ast.sz[0],ast.sz[1],3)
bw = 255 - bytscl(30 > irac < 180)
im[*,*,1]=  bw
im[*,*,0] = (bw + 1.5*bytscl(jcmt > 1.5) ) < 255
im[*,*,2] = (bw + 0*bytscl(co > 30) ) < 255

tvscl, im, true=3

stop
out=tvrd(/true)
write_png,'29densefig.png',out

end
