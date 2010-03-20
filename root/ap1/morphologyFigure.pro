;+
; NAME:
;  morphologyFigure
;
; DESCRIPTION:
;  Make morphology figure plots for paper. Taken from paperFigure
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
pro morphologyFigure, bubble, out = out, spawn = spawn, nosetup = nosetup
compile_opt idl2

p_multi_old = !p.multi
if n_params() eq 0 then bubble = 36

if keyword_set(out) then begin
    if ~keyword_set(nosetup) then begin
        set_plot, 'x'
        window, xsize = 1100, ysize = 850, /pixmap
        pageInfo = pswindow(/land)
        set_plot, 'ps'
        !p.font = 0
        device, /color, bits = 8, file='~/paper/figs/'+string(bubble,format='(i3.3)')+'_morph.ps', $
          _extra = pageInfo,/inches, /helvetica, /isolatin1
    endif
endif

;- PROGRAM CONSTANTS
eta = 0.7 ;-eta_fss
!p.charsize = 1.5
p_master = [.10, .05, .92, .92]
scale = [[5, 0], [14, .9], [15, 1.5], [21, 1], [22, .9], $
         [29,.5], [30, 1], [36, 1], [37, .8], [39, .9], [40, .8], $
         [45, 1.1], [46, .5], [47, .5], [49, 1], [50, .6], [52, .9], $
         [53, .9], [54, 1], [61, 1.5], [62, 1]]
hit = where(scale[0,*] eq bubble, ct)
if ct eq 0 then begin
    print, 'scale not found'
    scale = 0
endif else scale = scale[1,hit[0]]

;-read in files
;;jcmt

jcmt = '/users/cnb/harp/bubbles/reduced/N'+string(bubble,format='(i3.3)')+'.fits'
if ~file_test(jcmt) then message,'JCMT file not found: '+jcmt

jcmt = mrdfits(jcmt, 0,h,/silent)
jcmt /= eta
ast = nextast(h)

restore, file = '/users/cnb/glimpse/pro/shells/saved/'+string(bubble,format='(i3.3)')+'.sav'

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


;;hco
hco = '/users/cnb/harp/bubbles/reduced/N'+string(bubble,format='(i3.3)')+'H.fits'
if ~file_test(hco) or bubble eq 45 then begin
    print, 'No HCO+ file. Skipping.'
    isHCO = 0
    hco = jcmt * 0
    goto, jcmtplot
endif

isHCO = 1
hco = mrdfits(hco, 0, hch, /silent)
hast = nextast(hch)
hco /= eta
hco /= eta

velocity = getbubblevel(bubble)
velocity = (velocity - hast.crval[2])/hast.cd[2,2] + hast.crpix[2] - 1
hco = max(hco[*,*,min(velocity):max(velocity)],/nan, dimen=3) > 0

sxdelpar, hch, 'crval3'
sxdelpar, hch, 'crpix3'
sxdelpar, hch, 'cd3_3'
sxaddpar, hch, 'naxis', 2

cr = ((ast.sz[0:1] + 1) / 2. - ast.crpix[0:1]) * ast.cd[[0,4]] + ast.crval[0:1]
hco = postagestamp(hco, hch, cr, ast.sz[0:1]*ast.cd[0], ast.cd[[0,4]],/nan)
hco = congrid(hco, ast.sz[0], ast.sz[1])

;-try to trim the edges
bad = where(~finite(hco) or hco eq 0)
ind = array_indices(hco, bad)

mask = fltarr(21, 21)
backup = hco
for i = 0, n_elements(ind[0,*]) -1 do begin
    hco[0 > (ind[0,i] - 15) : $
        (ind[0,i] + 15) < (ast.sz[0] - 1), $
        0 > (ind[1,i] - 15) : $
        (ind[1,i] + 15) < (ast.sz[1] - 1)] = 0
endfor

jcmtplot:
;- set up plot windows
!p.multi = [0, 2, 1]
imannotate, ast, nxtick, nytick, xt, yt, xtv, ytv
ak = {xtitle:textoidl('\Delta l (arcmin)'), ytitle:textoidl('\Delta b (arcmin)'), $
      xtickv: xtv, xtickname:xt, ytickv: ytv, ytickname:yt, xticks:nxtick, yticks:nytick, xmin : 2, $
     ymin: 2, ticklen : -.025, charsize : 2.0} 

;-------------PLOT 1: INTEGRATED INTENSITY ---------------
loadct, 3,/silent
tvlct, r, g, b, /get

if ~keyword_set(out) then window, xsize = 1100, ysize = 850
p = p_master

cobyte = nanscale(maxMap)
hcobyte = isHCO ? nanscale(hco) : cobyte * 0B
alpha = isHCO ? hcobyte / 255. : hcobyte


col = bytarr(3, ast.sz[0], ast.sz[1])
col[0,*,*] = r[cobyte] * (1 - alpha) + alpha * b[hcobyte]
col[1,*,*] = g[cobyte] * (1 - alpha) + alpha * g[hcobyte]
col[2,*,*] = b[cobyte] * (1 - alpha) + alpha * r[hcobyte]

tvimage, col, position=p, /keep
;tvimage, nanscale(maxMap), /axes, position=p, /keep, axkeywords=ak  

;ticks = min(maxMap,/nan) + findgen(7) / 6 * (max(maxMap,/nan) - min(maxMap,/nan))
;ticks = string(ticks, format='(i3)')
bstring = 'N'+strtrim(bubble,2)
;colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=bstring+' Peak CO 3-2 Intensity (K)', $
;  ticknames = ticks

!p.multi[0]++
contour, shellmask, c_color=fsc_color('sky blue'), c_thick = 3, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2,/nodata, ticklen = -.025

xyoutsize = 1.5

if isHCO then begin
    xloc = !x.window[0] + 0.05 * (!x.window[1] - !x.window[0])
    align = 0
endif else begin
    xloc = (!x.window[0] + !x.window[1]) / 2.
    align = .5
endelse

yloc = !y.window[1] + .1 * (!y.window[1] - !y.window[0])
xyouts, xloc, yloc, 'CO (J = 3-2)', $
  /normal, color = fsc_color('crimson'), align = align, size = xyoutsize

if isHCO then begin
    xyouts, !x.window[1] - 0.05 * (!x.window[1] - !x.window[0]), yloc, $
      'HCO+ (J = 4-3)', /normal, color = fsc_color('sky blue'), align=1, size = xyoutsize
endif

!p.multi[0]--

;----------------
;---------PLOT 3: IRAC / VLA MAP -----------------------------

vlaplot: 

irac = mrdfits('/users/cnb/irac/'+string(bubble,format='(i3.3)')+'.fits', 0, hi, /silent)
sxaddpar, hi, 'crpix1', (sxpar(hi, 'naxis1') -1)/ 2.

irac = postagestamp(irac, hi, cr, ast.sz[0:1]*ast.cd[1,1], [-1,1]*3/3600.,/nan)
bad = where(~finite(irac),ct)
if ct ne 0 then irac[bad] = median(irac)

if bubble eq 15 then begin
    irac= 100 > irac < 600
endif else if bubble eq 61 then begin
    irac = 50 > irac < 200
endif else if bubble eq 62 then begin
    irac = 50 > irac < 200
endif else begin
    test = irac * 0
    for i = 0, 9, 1 do test += sigrange(irac, fraction = .99)
    irac = test / 10
endelse


vla = '/users/cnb/magpis/20/'+string(bubble,format='(i3.3)')+'.fits'

if ~file_test(vla) then begin
    print,'VLA file DNE. Skipping'
    vla = irac * 0
    goto, iracplot
endif

vla = mrdfits(vla,0,hv,/silent)
cd = sxpar(hv, 'cdelt2')
vla = postagestamp(vla, hv, cr, ast.sz[0:1] * ast.cd[0,0], [-1,1]*3/3600., /nan)
vla = congrid(vla, n_elements(irac[*,0]), n_elements(irac[0,*]))

maj = sxpar(hv,'bmaj') / 2.355 ;- degrees
min = sxpar(hv,'bmin') / 2.355 ;- degrees
beamsize = 2* !pi * maj * min  ;- square degrees
vla /= beamsize ;- Jy / square degrees
vla = vla / 1d6 * !radeg^2 ;- MJy / sr

test = vla * 0
for i = 0, 9 do test += sigrange(vla, fraction = 0.99)
vla = test / 10.

iracplot:
color = bytarr(3, n_elements(irac[*,0]), n_elements(irac[0,*]))
if scale le 1 then begin
    color[0,*,*] = byte( scale * nanscale(vla))
    color[1,*,*] = nanscale(irac)
    color[2,*,*] = nanscale(irac)
endif else begin
    color[0,*,*] = nanscale(vla)
    color[1,*,*] = byte(nanscale(irac) / scale)
    color[2,*,*] = byte(nanscale(irac) / scale)
endelse

p=p_master
tvimage, color, position = p,/keep


!p.multi[0]++
contour, shellmask, c_color=fsc_color('sky blue'), c_thick = 3, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2,/nodata, ticklen = -.025
  
if scale gt 0 then begin
    spitx = !x.window[0] + 0.05 * (!x.window[1] - !x.window[0])
    align = 0
endif else begin
    spitx = (!x.window[0] + !x.window[1]) / 2.
    align = .5
endelse

yloc = !y.window[1] + .1 * (!y.window[1] - !y.window[0])
mu = textoidl('\mu')
xyouts, spitx, yloc, $
  '8 '+mu+'m emission', /normal, color = fsc_color('sky blue'), align = align, size=xyoutsize

if scale gt 0 then begin
    xyouts, !x.window[1] - 0.05 * (!x.window[1] - !x.window[0]), yloc, $
      '20 cm emission', /normal, color = fsc_color('crimson'), align=1, size=xyoutsize
endif


if keyword_set(out)  && ~keyword_set(nosetup) then begin
    device,/close
    if KEYWORD_SET(spawn) then $
      spawn, 'gv ~/paper/figs/'+string(bubble,format='(i3.3)')+'_morph.ps &'
    set_plot, 'X'
endif

!p.multi = p_multi_old

end
;---------
