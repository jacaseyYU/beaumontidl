;+
; NAME:
;  AVIRACTEST
;
; DESCRIPTION:
;  A suite of tests to explore how the NICER algorithm depends on the
;  control field used.
;
; RESULTS:
;  The orion field and JSwift control field have color differences of
;  .011 and .051 mag (J-H and H-K). This translates into systematic Av
;  errors of .1 and .81 mag, respectively. 
;-

pro aviractest

;- colors
blue = fsc_color('sky blue', 0)
red = fsc_color('crimson', 1)
green = fsc_color('forest green', 2)
yellow = fsc_color('goldenrod', 3)

;-js's catalog
readcol, 'control.dat', ra, dec, j, dj, h, dh, k, dk, /silent
js = transpose([[j],[dj],[h],[dh],[k],[dk]])

;-the orion catalog
orion = fltarr(6, 16078)
a = ''
columns = [7, 9, 10, 12, 13, 15]

openr, 1, '2mass_control_orion.tbl'
skip_lun, 1, 54, /lines

nrec = 0L
while ~eof(1) do begin
    readf, 1, a
    temp=strsplit(a, ' ',/extract)
    if temp[16] ne '000' || max(temp[columns] eq 'null') ne 0 then continue
    orion[*,nrec++] = temp[columns]
endwhile
close, 1

orion = orion[*,0:nrec-1]

;- the taurus catalog
restore, file='taurus.sav'
in = where(((taurus.ra - 67.42)^2 + (taurus.dec - 25.50)^2) le (12.5 * .025)^2)
taurus = taurus[in]
;av = nicer(taurus.magj, taurus.dmagj, taurus.magh, taurus.dmagh, taurus.magk, taurus.dmagk)
;good = where(av[0,*] le 6)
;taurus = taurus[good]

;-glimpse field 1 / 2
;- both GLIMPSE fields were chosen because they look dark in the 1420
;  MHz BONN survey

restore, file = '58.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50 $
             and glimic.mag1 le 50 and glimic.mag2 le 50 and glimic.mag3 le 50 and $
             glimic.l ge 58.22 and glimic.l le 58.85 and glimic.b le -.75)
glimic = glimic[good]
glimic1 = transpose([[glimic.magj], [glimic.dmagj], $
                     [glimic.magh], [glimic.dmagh] ,$
                     [glimic.magk], [glimic.dmagk], $
                     [glimic.mag1], [glimic.dmag1], $
                     [glimic.mag2], [glimic.dmag2]])

;- glimpse field 2 / 2
restore, file = '63.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50 $
             and glimic.mag1 le 50 and glimic.mag2 le 50 and glimic.mag3 le 50 $
             and glimic.l ge 63.85 and glimic.b ge .2 and glimic.b le .5)
glimic = glimic[good]
glimic2 = transpose([[glimic.magj], [glimic.dmagj], $
                     [glimic.magh], [glimic.dmagh] ,$
                     [glimic.magk], [glimic.dmagk], $
                     [glimic.mag1], [glimic.dmag1], $
                     [glimic.mag2], [glimic.dmag2]])

;------ PLOT ONE ---------
;-plot orion av histograms with three different control fields
;-looks like about a .3 mag systematic offset
;------------------------

avcontrol, js[[0,2,4],*], color, covar
av1 = nicer(orion[0,*], orion[1,*], orion[2,*], orion[3,*], orion[4,*], orion[5,*], color = color, covar = covar)
avcontrol, orion[[0,2,4],*], color, covar
av2 = nicer(orion[0,*], orion[1,*], orion[2,*], orion[3,*], orion[4,*], orion[5,*], color = color, covar = covar)
avcontrol, transpose([[taurus.magj], [taurus.magh], [taurus.magk]]), color, covar
av3 = nicer(orion[0,*], orion[1,*], orion[2,*], orion[3,*], orion[4,*], orion[5,*], color = color, covar = covar)

h1 = histogram(av1[0,*], binsize=.1, loc=loc1)
h2 = histogram(av2[0,*], binsize=.1, loc = loc2)
h3 = histogram(av3[0,*], binsize=.1, loc=loc3)
r = [minmax(loc1),minmax(loc2), minmax(loc3)]
xra = [min(r),max(r)]
plot, [0],[0], yra=[0,1.05],xra=xra,/xsty,/ysty,/nodata
oplot, loc1, 1.0 * h1 / max(h1), color = blue, psym = 10
oplot, loc2, 1.0 * h2 / max(h2), color = red, psym = 10
oplot, loc3, 1.0 * h3 / max(h3), color = yellow, psym = 10

xyouts, 5, .9, 'JS Colors', color = blue, /data, charsize=1.5
xyouts, 5, .8, 'Orion Colors', color = red, /data, charsize=1.5
xyouts, 5, .7, 'Taurus Colors', color = yellow, /data, charsize = 1.5

;-------PLOT TWO -----------
;  Plot a GLIMPSE field Av measurment with two control fields against
;  the default av measurement. Can be
;  used to confirm that using a different control field effects all
;  Avs by the same amount (hence, differences in AVs are independent
;  of the control field
;--------------------------
av1 = nicer(glimic1[0,*], glimic1[1,*], glimic1[2,*], glimic1[3,*], glimic1[4,*], glimic1[5,*])
avcontrol, orion[[0,2,4],*], color, covar
av2 = nicer(glimic1[0,*], glimic1[1,*], glimic1[2,*], glimic1[3,*], glimic1[4,*], glimic1[5,*], color=color, covar=covar)
avcontrol, transpose([[taurus.magj], [taurus.magh], [taurus.magk]]), color, covar
av3 = nicer(glimic1[0,*], glimic1[1,*], glimic1[2,*], glimic1[3,*], glimic1[4,*], glimic1[5,*], color=color, covar=covar)

xra = minmax(av1[0,*])
yra = minmax(av1[0,*] - [av2[0,*], av3[0,*]])
plot, av1[0,*], av1[0,*] - av2[0,*], /nodata, xra=xra,yra=yra, xtitle='Default Av', ytitle='Different Control Field Av'
oplot, av1[0,*], av1[0,*] - av2[0,*], psym=3, color = red
oplot, av1[0,*], av1[0,*] - av3[0,*], psym=3, color = blue


;------ PLOT THREE ---------
;- plot histograms of the three control fields. 
;- Looks like the taurus field is biased towards higher extinction,
;  but is within 1 mag of being centered at zero.
;-------------------------
av1 = nicer(js[0,*], js[1,*], js[2,*], js[3,*], js[4,*], js[5,*])
av2 = nicer(orion[0,*], orion[1,*], orion[2,*], orion[3,*], orion[4,*], orion[5,*])
av3 = nicer(taurus.magj, taurus.dmagj, taurus.magh, taurus.dmagh, taurus.magk, taurus.dmagk)

h1 = histogram(av1[0,*], binsize=.3, loc=loc1)
h2 = histogram(av2[0,*], binsize=.3, loc=loc2)
h3 = histogram(av3[0,*], binsize=.3, loc = loc3)

r = [minmax(loc1),minmax(loc2),minmax(loc3)]
xra = [min(r),max(r) < 10]
plot, [0],[0], yra=[0,1.05],xra=xra,/xsty,/ysty,/nodata, xtitle='Av', ytitle='Fraction', charsize=1.5
oplot, loc1, 1.0 * h1 / max(h1), color = blue, psym = 10
oplot, loc2, 1.0 * h2 / max(h2), color = red, psym = 10
oplot, loc3, 1.0 * h3/ max(h3), color = green, psym=10

xyouts, 6, 1, 'JS Field', /data, charsize=1.5, color= blue
xyouts, 6, .9, 'Orion Field', /data, charsize=1.5, color = red
xyouts, 6, .8, 'Taurus Field', /data, charsize=1.5, color = green


;- test out old nicer and new nicer- make sure results are the same
dummy = fltarr(908) + 10000
av1 = nicer(glimic2[0,*], glimic2[1,*], glimic2[2,*], glimic2[3,*], glimic2[4,*], glimic2[5,*])
av2 = nicer_dev(glimic2[0,*], glimic2[1,*], glimic2[2,*], glimic2[3,*], glimic2[4,*], glimic2[5,*], $
               glimic2[6,*], dummy, glimic2[8,*], dummy)

plot, av1[0,*] - av2[0,*], psym = 3

;- test out new nicer with extra colors. Make sure that the AVs have
;  the same expectation values
av3 = nicer_dev(glimic2[0,*], glimic2[1,*], glimic2[2,*], glimic2[3,*], glimic2[4,*], glimic2[5,*], $
               glimic2[6,*], glimic2[7,*], glimic2[8,*], glimic2[9,*])

plot, av1[0,*], av1[0,*] - av3[0,*], psym=3, xtitle = '3 band AV', ytitle = '3 band AV - 5 band AV'
oplot, [-20, 20], [0, 0], color = red
stop 



end
