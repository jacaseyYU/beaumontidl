;+
; Compute the average YSO source density inside a bubble
; Uses bubble region files from the shellstat program
;-

function BubbleSourceTag, bubble
compile_opt idl2

if n_params() ne 1 then begin
    print, 'BubbleSourceTag calling sequence: result= bubbleSourceTag(bubble number)'
    return, -1
endif

;-read in the .SAV file which defines the shell location
shellfile = '/users/cnb/glimpse/pro/shells/saved/'+string(bubble,format='(i3.3)')+'.sav'
if ~file_test(shellfile) then message, 'Shell file not found: '+shellfile

restore, shellfile  ;- restores CAST (astrometry struct) and shellmask
;- use shellmask and cast to determine which GLIMPSE .sav file to read
masksz = size(shellmask)
l_lim = ([0,masksz[1]] - cast.crpix[0] + 1) * cast.cd[0,0] + cast.crval[0]
longitude = mean(l_lim)
l_lim = floor(l_lim)

;- restore ircat
restore, string(l_lim[0],format='(i2.2)')+'.sav' ;-restores GLIMIC struct
cat = glimic

if l_lim[0] ne l_lim[1] then begin
    restore, string(l_lim[1],format='(i2.2)')+'.sav' ;-restores GLIMIC struct
    glimic = [cat, glimic]
endif

;- tag YSOs
yso = ysotag(glimic.mag1, glimic.mag2, glimic.mag3, glimic.mag4)
bad = where((glimic.mag1 ge 90) or (glimic.mag2 ge 90) $
            or (glimic.mag3 ge 90) or (glimic.mag4 ge 90), ct)
if ct ne 0 then yso[bad] = 3B

;- determine which sources are in the bubble
inside = bubblemask(bubble, glimic.l, glimic.b)

;- count up source hits
shellarea = total(shellmask) * abs(cast.cd[0,0])^2 * 3600 ;- in sq arcmin
shellhits = total(yso ne 3 and inside)

;- display results
contour, shellmask
hit = where(inside and yso ne 3, ct)
if ct ne 0 then begin
    x_pix = (glimic[hit].l - cast.crval[0]) / cast.cd[0,0] + cast.crpix[0] - 1
    y_pix = (glimic[hit].b - cast.crval[1]) / cast.cd[1,1] + cast.crpix[1] - 1
    oplot, [x_pix], [y_pix], psym = 2, color='00ff00'xl
endif

return, [shellarea, shellhits, longitude]

end
