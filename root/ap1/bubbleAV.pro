;+
; Estimates the AV of a given bubble, and creates an AV map of the
; surrounding region
;
; Caveat: Don't currently have a self-contained control field to
; calibrate colors. Need to somehow estiamte the size of the error
; this induces (e.g. compare js region to the orion 2mass region)
;
; UPDATE: The program aviractest runs some tests to explore the
; sensitivity of the av measurement on the control field. For js
; and orion fields, the change is very small (< error). I tried
; to use the taurus spitzer legacy survey to get IRAC colors, but
; am running into discrepancies with that field - likely due to the 
; inability to find a low extinction region (but I'm not sure)
;-

pro bubbleAV, bubble

pos = getBubblePos(bubble)
r2 = ((pos[1,0] - pos[0,0])^2 > (pos[1,1] - pos[0,1])^2) / 4.

restore, string(floor(pos[0,0]), format="(i2.2, '.sav')")
nearby = where( ((glimic.l - mean(pos[*,0]))^2 + $
                (glimic.b - mean(pos[*,1]))^2) lt 3 * r2 )
cat = glimic[nearby]


if (pos[0,0] mod 1) ge .5 then begin
    restore, string(floor(pos[0,0] +1), format="(i2.2, '.sav')")
endif else begin
    restore, string(floor(pos[0,0] -1), format="(i2.2, '.sav')")
endelse

nearby = where( ((glimic.l - mean(pos[*,0]))^2 + $
                (glimic.b - mean(pos[*,1]))^2) lt 3 *r2, ct )
if ct ne 0 then glimic = [cat, glimic[nearby]] else glimic = cat
   
av = nicer_dev(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk, $
                glimic.mag1, glimic.dmag1, glimic.mag2, glimic.dmag2)
pass = where(av[1,*] lt 7)
glimic = glimic[pass]
av = av[*,pass]

inside = bubblemask(bubble, glimic.l, glimic.b)
hit = where(inside, complement = miss)

weight = 1 / av[1,hit]^2
avin = total(av[0, hit] * weight) / total(weight)
eavin = sqrt(total(av[1,hit]^2 * weight^2) / total(weight^2))

weight = 1 / av[1,miss]^2
avout = total(av[0,miss] * weight) / total(weight)
eavout = sqrt(total(av[1,miss]^2 * weight^2) / total(weight^2))

print, 'Quantitites from individual points:'
print, avin, eavin, format=  '("Av in:  ", f4.1, "+/-", f4.2)'
print, avout, eavout, format='("Av out: ", f4.1, "+/-", f4.2)'

avdiff = avin - avout
davdiff = sqrt(eavin^2 + eavout^2)
print, avdiff, davdiff, format='("Shell Av: ", f4.1, "+/-", f4.2)'

smoothmap, av[0,*], av[1,*], glimic.l, glimic.b, map, emap, ctmap, head, fwhm = 1 / 60., $
  out = '/users/cnb/avmaps/'+string(bubble, format='(i2)'),/clip

ast = nextast(head)
x = (findgen(ast.sz[0]) - ast.crpix[0] + 1) * ast.cd[0,0] + ast.crval[0]
y = (findgen(ast.sz[1]) - ast.crpix[1] + 1) * ast.cd[1,1] + ast.crval[1]

shmask = bubblemask(bubble, rebin(x, ast.sz[0], ast.sz[1]), rebin(1#y, ast.sz[0], ast.sz[1]))
sz = size(map)
loadct, 3, /silent
im = bytscl(map ,/nan)
levs = min(map,/nan) + findgen(5) * (max(map,/nan) - min(map,/nan)) / 4.

erase
position = [.05, .05, .9, .9]
tvimage, im, position= position, /keep
contour, shmask, color='00ff00'xl, /noerase, position = position, /xsty, /ysty, c_thick = 2

hit = where(shmask, complement = miss)
weight = 1 / emap[hit]^2
avin = total(map[hit] * weight,/nan) / total(weight,/nan)
eavin = sqrt(total(emap[hit]^2 * weight^2) / total(weight^2))

weight = 1 / emap[miss]^2
avout = total(map[miss] * weight,/nan) / total(weight,/nan)
eavout = sqrt(total(emap[miss]^2 * weight^2,/nan) / total(weight^2,/nan))

print, 'Quantities from Smoothed Map:'
print, avin, eavin, format=  '("Av in:  ", f4.1, "+/-", f4.2)'
print, avout, eavout, format='("Av out: ", f4.1, "+/-", f4.2)'

avdiff = avin - avout
davdiff = sqrt(eavin^2 + eavout^2)
print, avdiff, davdiff, format='("Shell Av: ", f4.1, "+/-", f4.2)'


end
