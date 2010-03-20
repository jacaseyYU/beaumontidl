;-make an image of IRXS clumping
pro xsfig

im=mrdfits('~/glimpse/fits/i4/40_i4.fits',0,h,/silent)
restore,'~/glimpse/pro/25.sav'

ast=nextast(h)

print, 'finding xs sources'
;-find xs sources
good = where((glimic.mag1 le 90) and (glimic.mag2 le 90) and (glimic.mag3 le 90) and (glimic.mag4 le 90))
glimic=glimic[good]
xs = where( ((glimic.mag1 - glimic.mag2) gt .8) or ((glimic.mag3 - glimic.mag4) gt 1.1) $
            or (((glimic.mag1 - glimic.mag2) gt 0) and (glimic.mag3-glimic.mag4) gt .4), ct)
loadct,0
window, 0, xsize=ast.sz[0], ysize=ast.sz[1], retain=2
tvscl, 90 > im < 180
tvlct, fsc_color('CRIMSON',/triple),255
x = (glimic[xs].l - ast.crval[0])/ast.cd[0,0] + ast.crpix[0]-1
y = (glimic[xs].b - ast.crval[1])/ast.cd[1,1] + ast.crpix[1]-1
plots, x, y, /device, color=255, psym = 6, symsize=2.0 
out=tvrd(/true)
write_png,'40_xs.png',out
stop
end
