;+
; NAME:
;  dopplerFigure
;
; DESCRIPTION:
;  Create a doppler map of a bubble. Taken from paperFigure
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

pro dopplerFigure, bubble, out = out, spawn = spawn, nosetup = nosetup
compile_opt idl2

p_multi_old = !p.multi
if n_params() eq 0 then bubble = 45

if keyword_set(out) then begin
    if ~keyword_set(nosetup) then begin
        set_plot, 'x'
        window, xsize = 1100, ysize = 850, /pixmap
        pageInfo = pswindow(/land)
        set_plot, 'ps'
        !p.font = 0
        device, /color, bits = 8, file='~/paper/figs/'+string(bubble,format='(i3.3)')+'_doppler.ps', $
          _extra = pageInfo,/inches, /helvetica, /isolatin1
    endif
endif

;- PROGRAM CONSTANTS
eta = 0.7 ;-eta_fss
!p.charsize = 2.0
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



jcmtplot:
;- set up plot windows
!p.multi = 0
imannotate, ast, nxtick, nytick, xt, yt, xtv, ytv
ak = {xtitle:textoidl('\Delta l (arcmin)'), ytitle:textoidl('\Delta b (arcmin)'), $
      xtickv: xtv, xtickname:xt, ytickv: ytv, ytickname:yt, xticks:nxtick, yticks:nytick, xmin : 2, $
     ymin: 2, ticklen : -.025, charsize : 2.0} 

;----------PLOT 2: DOPPLER MAP -----------------------------
;loadct, 34, /silent ;-rainbow
;tvlct, r,g,b, /get
image = fltarr(3, ast.sz[0], ast.sz[1])

d1 = 2
d2 = -12
nz = max(velocity) - min(velocity)
n0 = min(velocity) + nz / 3 + d1
n1 = min(velocity) + 2 * nz / 3 + d2
print, ([min(velocity),n0,n1,max(velocity)] - ast.crpix[2] + 1) * ast.cd[2,2] + ast.crval[2]

image[2,*,*] = total(jcmt[*,*,min(velocity):n0], 3, /nan) 
image[1,*,*] = total(jcmt[*,*,n0+1:n1], 3, /nan)
image[0,*,*] = total(jcmt[*,*,n1+1:max(velocity)],3,/nan) 

image = nanscale(image)
bstring = 'N'+strtrim(bubble,2)
p=p_master
erase
tvimage, image, /axes, position=p, /keep, axkeywords = ak,/true  
loadct, 34, /silent ;-rainbow
tvlct, 0,0,0,0 ;-make the first entry black for correct PS output of text
ticks = min(moment,/nan) + findgen(7) / 6 * (max(moment,/nan) - min(moment,/nan))
ticks = string(ticks, format='(i3)')
;colorbar, position = [p[0], p[3] + .03, p[2], p[3]+.05], title=bstring+' Mean CO 3-2 velocity (Km/s)', $
;  ticknames = ticks, charsize = 1.25

if keyword_set(out)  && ~keyword_set(nosetup) then begin
    device,/close
    if KEYWORD_SET(spawn) then $
      spawn, 'gv ~/paper/figs/'+string(bubble,format='(i3.3)')+'.ps &'
    set_plot, 'X'
endif

!p.multi = p_multi_old

end
;---------
