pro anim
;- animate 36 spectral cube

im = mrdfits('~/harp/bubbles/reduced/N022.fits',0,h,/silent)

ast = nextast(h)

vlo = (57 - ast.crval[2])/ast.cd[2,2] + ast.crpix[2] -1
vhi = (47 - ast.crval[2])/ast.cd[2,2] + ast.crpix[2] - 1

window, 0, retain=2, xsize=ast.sz[0], ysize=ast.sz[1], xpos = 0, ypos = 500
loadct, 33
tvlct, r, g, b, /get

im[where(~finite(im))]=0

im = bytscl( 3 > im < 25)
color = bytarr(3, ast.sz[0],ast.sz[1])

for i=0, (vhi-vlo)-1, 1 do begin
    color[0,*,*] = r[ 1. * i/(vhi-vlo) * 255]/255. * im[*,*,vlo+i]
    color[1,*,*] = g[ 1. * i/(vhi-vlo) * 255]/255. * im[*,*,vlo+i]
    color[2,*,*] = b[ 1. * i/(vhi-vlo) * 255]/255. * im[*,*,vlo+i]
    tv, color, /true
    write_png, '~/figures/anim/22_'+string(i,format='(i3.3)')+'.png', $
      color
    wait, .1
endfor

;- repeat for ratran bubble
nstep = round((vhi-vlo))
sim = mrdfits('~/ratran/bubbles/sim/typ.fits',0,h,/silent)
ast = nextast(h)

window, 0, xsize=ast.sz[0], ysize=ast.sz[1], xpos = 0, ypos = 600, retain=2
sim = bytscl(sim)
color = bytarr(3, ast.sz[0], ast.sz[1])
for i=0, nstep-1, 1 do begin
    color[0,*,*] = r[ (1. * i)/nstep * 255]/255. * sim[*,*, 1. * i/nstep * (ast.sz[2]-1) ]
    color[1,*,*] = g[(1. * i)/nstep * 255]/255. * sim[*,*, 1. * i/nstep * (ast.sz[2]-1) ]
    color[2,*,*] = b[(1. * i)/nstep * 255]/255. * sim[*,*, 1. * i/nstep * (ast.sz[2]-1) ]
    tv, color, /true
    write_png, '~/figures/anim/sim_'+string(i,format='(i3.3)')+'.png', $
      color
    wait, .1
endfor


end
