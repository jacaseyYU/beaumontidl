;+
; NAME:
;  paperFigure
;
; DESCRIPTION:
;  Create a suite of figures for a bubble for the ApJ paper
;-

;---------
;---------
pro imannotate, ast, nxtick, nytick, xt, yt, xtv, ytv

;- set up image annotation
;- ticks at every 2 arcmin

nxtick = floor(ast.sz[0] * ast.cd[1,1] * 60 / 2) / 2 * 2 + 1
nytick = floor(ast.sz[1] * ast.cd[1,1] * 60 / 2) / 2 * 2 + 1

xt = (indgen(nxtick) - (nxtick-1) / 2.) * 2
yt = (indgen(nytick) - (nytick-1) / 2.) * 2

xtv = [ast.sz[0] / 2. + xt / 60. / ast.cd[0,0]]
ytv = [ast.sz[1] / 2. + xt / 60. / ast.cd[1,1]]

xt = [string(xt, format='(i3)')]
yt = [string(yt, format='(i3)')]

nxtick -=1
nytick -=1
end
;---------
;--------

pro paperFigure, bubble, out = out, spawn = spawn, nosetup = nosetup
compile_opt idl2

p_multi_old = !p.multi
if n_params() eq 0 then bubble = 36

if keyword_set(out) then begin
    if ~keyword_set(nosetup) then begin
        set_plot, 'x'
        window, xsize = 1100, ysize = 850, /pixmap
        pageInfo = pswindow(/land)
        set_plot, 'ps'
        device, /color, bits = 8, file='~/paper/figs/'+string(bubble,format='(i3.3)')+'.eps', $
          /encapsulated, /preview, _extra = pageInfo,/inches
    endif
endif

;- PROGRAM CONSTANTS
eta = 0.7 ;-eta_fss

jcmt = '/users/cnb/harp/bubbles/reduced/N'+string(bubble,format='(i3.3)')+'.fits'
if ~file_test(jcmt) then message,'JCMT file not found: '+jcmt

jcmt = mrdfits(jcmt, 0,h,/silent)
jcmt /= eta
ast = nextast(h)
restore, file = '/users/cnb/glimpse/pro/shells/saved/'+string(bubble,format='(i3.3)')+'.sav'

hco = '/users/cnb/harp/bubbles/reduced/N'+string(bubble,format='(i3.3)')+'_H.fits'
if file_test(hco) then begin
    hco = mrdfits(jcmt, 0, hh, /silent)
endif

velocity = getbubblevel(bubble)
vbak = velocity
velocity = (velocity - ast.crval[2])/ast.cd[2,2] + ast.crpix[2] - 1
sum = total(jcmt[*,*,min(velocity):max(velocity)],/nan, 3) * abs(ast.cd[2,2])
maxmap = max(jcmt[*,*,min(velocity):max(velocity)],/nan, dimension=3)

;- moment map
v0 = ast.cd[2,2] gt 0 ? min(vbak): max(vbak)
v1 = ast.cd[2,2] gt 0 ? max(vbak): min(vbak)
nch = max(velocity) - min(velocity) + 1
vels = findgen(nch) / (nch - 1.) * (v1 - v0) + v0
vels = rebin(reform(vels, 1, 1, nch), ast.sz[0], ast.sz[1], nch)
trim = jcmt[*,*, min(velocity) : max(velocity)]
bad = where(trim lt 0, ct)
if ct ne 0 then trim[bad] = !values.f_nan
trim /= rebin(total(trim,3,/nan), ast.sz[0], ast.sz[1], nch)
moment = total(trim * vels, 3,/nan)
moment = (.75 * min(vbak) + .25 * max(vbak)) > moment < (.75 * max(vbak) + .25 * min(vbak))

loc = getbubblepos(bubble)
restore,file=strtrim(floor(loc[0,0]),2)+'.sav'
cat = glimic
if (loc[0,0] mod 1) ge .5 then begin
    new = strtrim(floor(loc[0,0]+1),2)+'.sav'
endif else new = strtrim(floor(loc[0,0]-1),2)+'.sav'

restore, file=new
glimic = [cat, glimic]

x = (glimic.l - ast.crval[0])/ast.cd[0,0] + ast.crpix[0] - 1
y = (glimic.b - ast.crval[1])/ast.cd[1,1] + ast.crpix[1] - 1
good = where( ( (glimic.l - ast.crval[0])^2 + $
                (glimic.b - ast.crval[1])^2 ) le $
              (max(ast.sz[0:1]) * ast.cd[0]) ^ 2 )
;good = where((x ge 0) and (x lt ast.sz[0]) and (y ge 0) and (y lt ast.sz[1]))

;good = where(bubblemask(bubble, glimic.l, glimic.b))
x = x[good]
y = y[good]
glimic = glimic[good]
yso = ysotag(glimic.mag1, glimic.mag2, glimic.mag3, glimic.mag4)


;- set up plot windows
!p.multi = [0, 3, 2]
imannotate, ast, nxtick, nytick, xt, yt, xtv, ytv
ak = {xtitle:textoidl('\Delta l (arcmin)'), ytitle:textoidl('\Delta b (arcmin)'), $
      xtickv: xtv, xtickname:xt, ytickv: ytv, ytickname:yt, xticks:nxtick, yticks:nytick, xmin : 2, $
     ymin: 2, ticklen : -.025} 
!p.charsize = 1.5
p_master = [.10, .05, .92, .92]

;-------------PLOT 1: INTEGRATED INTENSITY ---------------
loadct, 3,/silent

if ~keyword_set(out) then window, xsize = 1100, ysize = 850
p = p_master

tvimage, sum, /axes, position=p, /keep, /scale, axkeywords=ak  
ticks = min(sum,/nan) + findgen(7) / 6 * (max(sum,/nan) - min(sum,/nan))
ticks = string(ticks, format='(i3)')
colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title='Integrated CO 3-2 Intensity (K Km/s)', $
  ticknames = ticks


;----------PLOT 2: DOPPLER MAP -----------------------------
loadct, 34, /silent ;-rainbow
tvlct, r,g,b, /get
image = bytarr(3, ast.sz[0], ast.sz[1])
image[0,*,*] = byte(r[bytscl(moment)] * (sum > 0) / max(sum))
image[1,*,*] = byte(g[bytscl(moment)] * (sum > 0) / max(sum))
image[2,*,*] = byte(b[bytscl(moment)] * (sum > 0)/ max(sum))

p=p_master
tvimage, image, /axes, position=p, /keep, /scale, axkeywords = ak  
loadct, 34, /silent ;-rainbow
tvlct, 0,0,0,0 ;-make the first entry black for correct PS output of text
ticks = min(moment,/nan) + findgen(7) / 6 * (max(moment,/nan) - min(moment,/nan))
ticks = string(ticks, format='(i3)')
colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title='Mean CO 3-2 velocity (Km/s)', $
  ticknames = ticks



;---------PLOT 3: IRAC MAP -----------------------------
irac = mrdfits('/users/cnb/glimpse/fits/i4/'+strtrim(bubble,2)+'_I4.fits', 0, hi, /silent)
irac = postagestamp(irac, hi, ast.crval[0:1], ast.sz[0:1]*ast.cd[1,1], [-1,1]*1.2/3600.)
bad = where(~finite(irac),ct)
if ct ne 0 then irac[bad] = median(irac)
irac = sigrange(irac, fraction=.99)

p=p_master
loadct, 3, /silent

tvimage, irac, position = p,/keep, /scale
ticks = min(irac,/nan) + findgen(7) / 6 * (max(irac,/nan) - min(irac,/nan))
ticks = string(ticks, format='(i3)')
title = '8 '+TexToIDL('\mu')+'m Intensity (MJy / sr)'
colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=title, $
  ticknames = ticks

!p.multi[0]++
;plot, [0,ast.sz[0]-1], [0, ast.sz[1]-1], /nodata, , position=p
contour, shellmask, c_color=fsc_color('sky blue'), c_thick = 3, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2,/nodata, ticklen = -.025

;---------PLOT 4: YSO MAP ;---------------
!p.multi[0]--

ysotag = where(yso ne 3, ct)

;av = nicer_dev(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, $
;           glimic.magk, glimic.dmagk, glimic.mag1, glimic.dmag1, glimic.mag2, glimic.dmag2)
;good = where(av[1,*] le 5 and av[0,*] le 40)
;smoothmap, av[0,good], av[1,good], glimic[good].l, glimic[good].b, map, emap, ctmap, head
densitymap, glimic[ysotag].l, glimic[ysotag].b, 25, map, emap, head, /galactic, cdelt = 7.5 / 3600., /verbose

;-convert from sources / degree to sources/ arcmin
map /= 3600

cd = sxpar(head,'cdelt2')
map = postagestamp(map, head, ast.crval[0:1], ast.sz[0:1] * ast.cd[1,1], ast.cd[[0,4]],/nan)
map = congrid(map, ast.sz[0], ast.sz[1])

loadct, 34,/silent

p = p_master

tvimage, bytscl(map), position=p, /keep  
ticks = min(map,/nan) + findgen(7) / 6 * (max(map,/nan) - min(map,/nan))
ticks = string(ticks, format='(f4.1)')
colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=texToIDL('YSO Source density (arcmin^{-2})'), $
  ticknames = ticks

!p.multi[0]++
contour, shellmask, c_color=fsc_color('white'), c_thick = .5, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2, ticklen=-.025



;-------PLOT 5: VLA MAP -----------------------
!p.multi[0]--
vla = '/users/cnb/magpis/20/'+string(bubble,format='(i3.3)')+'.fits'

if ~file_test(vla) then begin
    print,'VLA file DNE. Skipping'
    goto, plot6
endif

vla = mrdfits(vla,0,hv,/silent)
cd = sxpar(hv, 'cdelt2')
vla = postagestamp(vla, hv, ast.crval[0:1], ast.sz[0:1] * ast.cd[0,0], [-cd, cd], /nan)
;vla = congrid(vla, ast.sz[0],ast.sz[1], cubic=-0.5)

maj = sxpar(hv,'bmaj') / 2.355 ;- degrees
min = sxpar(hv,'bmin') / 2.355 ;- degrees
beamsize = 2* !pi * maj * min  ;- square degrees
vla /= beamsize ;- Jy / square degrees
vla = vla / 1d6 * !radeg^2 ;- MJy / sr
vla = sigrange(vla, fraction = 0.98)

loadct, 3, /silent
p = p_master
tvimage, nanscale(vla), position=p, /keep  

ticks = min(vla,/nan) + findgen(7) / 6 * (max(vla,/nan) - min(vla,/nan))
ticks = string(ticks, format='(i4)')

colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=textoIDL('20 cm flux (MJy / sr)'), $
  ticknames = ticks

!p.multi[0]++
contour, shellmask, c_color=fsc_color('sky blue'), c_thick = 3, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2,/nodata, ticklen=-.025


;------PLOT 6- HCO+ map ----------------------
plot6:

hco = '/users/cnb/harp/bubbles/reduced/N'+string(bubble,format='(i3.3)')+'H.fits'
if ~file_test(hco) then begin
    print, 'No HCO+ file. Skipping.'
    return
endif

!p.multi[0]--

hco = mrdfits(hco, 0, hch, /silent)
hast = nextast(hch)
hco /= eta
hco /= eta

velocity = getbubblevel(bubble)
velocity = (velocity - hast.crval[2])/hast.cd[2,2] + hast.crpix[2] - 1
hco = total(hco[*,*,min(velocity):max(velocity)],/nan, 3) * abs(hast.cd[2,2]) > 0

sxdelpar, hch, 'crval3'
sxdelpar, hch, 'crpix3'
sxdelpar, hch, 'cd3_3'
sxaddpar, hch, 'naxis', 2

hco = postagestamp(hco, hch, ast.crval[0:1], ast.sz[0:1]*ast.cd[0], ast.cd[[0,4]],/nan)
hco = congrid(hco, ast.sz[0], ast.sz[1], cubic=-0.5)

loadct, 3, /silent
p = p_master
tvimage, nanscale(hco), /axes, position=p, /keep, axkeywords=ak
ticks = min(hco,/nan) + findgen(7) / 6 * (max(hco,/nan) - min(hco,/nan))
ticks = string(ticks, format='(i4)')

colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=textoIDL('HCO+ integrated intensity (K km/s)'), $
  ticknames = ticks


if keyword_set(out)  && ~keyword_set(nosetup) then begin
    device,/close
    if KEYWORD_SET(spawn) then $
      spawn, 'gv ~/paper/figs/'+string(bubble,format='(i3.3)')+'.eps &'
    set_plot, 'X'
endif

!p.multi = p_multi_old
end
;---------
