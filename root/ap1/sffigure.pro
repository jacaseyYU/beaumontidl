;+
; NAME:
;  sffigure
;
; DESCRIPTION:
;  Make SF figures for paper. Taken from morphfigure
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
pro sfFigure, bubble, out = out, spawn = spawn, nosetup = nosetup
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
        device, /color, bits = 8, file='~/paper/figs/'+string(bubble,format='(i3.3)')+'_sf.ps', $
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
cr = ((ast.sz[0:1] + 1) / 2. - ast.crpix[0:1]) * ast.cd[[0,4]] + ast.crval[0:1]

restore, file = '/users/cnb/glimpse/pro/shells/saved/'+string(bubble,format='(i3.3)')+'.sav'

velocity = getbubblevel(bubble)
vbak = velocity
velocity = (velocity - ast.crval[2])/ast.cd[2,2] + ast.crpix[2] - 1
sum = total(jcmt[*,*,min(velocity):max(velocity)],/nan, 3) * abs(ast.cd[2,2])
maxmap = max(jcmt[*,*,min(velocity):max(velocity)],/nan, dimension=3)



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

;----------------
!p.multi[0] = 1

;-restore glimic catalogs

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


ysotag = where(yso ne 3, ct)

densitymap, glimic[ysotag].l, glimic[ysotag].b, 15, map, emap, head, /galactic, cdelt = 7.5 / 3600., /verbose

;-convert from sources / degree to sources/ arcmin
map /= 3600

cd = sxpar(head,'cdelt2')
map = postagestamp(map, head, cr, ast.sz[0:1] * ast.cd[1,1], ast.cd[[0,4]],/nan)
map = congrid(map, ast.sz[0], ast.sz[1])

loadct, 34,/silent
tvlct, 0,0,0,0 ;-put black at index zero to get axes color right

p = p_master

tvimage, nanscale(map), position=p, /keep  
ticks = min(map,/nan) + findgen(7) / 6 * (max(map,/nan) - min(map,/nan))
ticks = string(ticks, format='(f4.1)')
colorbar, position = [p[0], p[3] + .04, p[2], p[3]+.065], title=texToIDL('YSO surface density (arcmin^{-2})'), $
  ticknames = ticks, charsize = 1.0

!p.multi[0] = 1
contour, shellmask, c_color=fsc_color('white'), c_thick = .5, position=p, /noerase,/xsty,/ysty, $
  xtitle =textoidl('\Delta l (arcmin)'), $
  ytitle = textoidl('\Delta b (arcmin)'), xtickv =  xtv, xtickname = xt, ytickv = ytv, $
  ytickname = yt, xticks = nxtick, yticks = nytick, xmin  =  2, ymin= 2, ticklen=-.025

if keyword_set(out)  && ~keyword_set(nosetup) then begin
    device,/close
    if KEYWORD_SET(spawn) then $
      spawn, 'gv ~/paper/figs/'+string(bubble,format='(i3.3)')+'_sf.ps &'
    set_plot, 'X'
endif

!p.multi = p_multi_old

end
;---------
