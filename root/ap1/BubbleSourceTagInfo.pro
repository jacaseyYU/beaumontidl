;+
; NAME:
;  BubbleSourceTagInfo
; 
; DESCRIPTION:
;  visualize Bubble source tag infromation generated in
;  bubblesourcetagdriver.pro (info.sav) and galaxysourcetag.pro (galinfo.sav)
pro BubbleSourceTagInfo

restore, file='info.sav'
restore, file='galinfo.sav'

good = where(info[0,*] ne 0, ct)


info = info[*,good]

shellct = info[1,*] / info[0,*]
shellerr = sqrt(info[1,*]) / info[0,*]

extct = galinfo / 7200. ;- sources per sq arcmin
exterr = sqrt(galinfo) / 7200.
gal_l = findgen(53) + 11

;- set up plots
window, xsize = 700, ysize = 700
pageInfo = pswindow(/land)
;set_plot, 'ps'
;device,file='XSPlot.eps',/color,bits = 8, /encapsulated, /preview, $
;  _extra = pageInfo

black = fsc_color('black')
white = fsc_color('white')
green = fsc_color('forest green')
red = fsc_color('crimson')

plot, info[2,*], shellct, psym = 4, xtitle = textoidl('Longitude ( ^{\circ} )'), ytitle = textoidl("YSOs arcmin^{-2}"), $
  title='YSO Surface Density', $
  yra = 1.1 * [min(shellct - shellerr), max(shellct + shellerr)], /ysty, $
  color = black, background = white, charsize=1.5

xyouts, 45, 4, textoidl('GLIMPSE average ( | b | < 1^{\circ})'), color = red, $
  /data, charsize=1.25
xyouts, 45, 3.75, 'Bubbles', color = black, /data, charsize=1.25

;-label the top three bubbles
xyouts, 25.5, 3, 'Bubble N34', color = black, /data
xyouts, 23, 2.2, 'Bubble N30', color = black, align = 1, /data
xyouts, 40, 1.8, 'Bubble N74', color = black, /data

for i = 0, n_elements(shellerr) - 1, 1 do begin
    oplot, [info[2,i], info[2,i]], shellct[i] + shellerr[i] * [-1, 1], psym = 0, thick=1.0, color=black
endfor

oplot, gal_l, extct, psym=0, color=red, thick = 2


for i = 0, n_elements(extct) - 1, 1 do begin
    oplot, gal_l[i] * [1,1], extct[i] + exterr[i] * [-1, 1], color=red, thick=2
endfor

;device,/close
;set_plot,'x'
;spawn, 'gv XSPlot.eps &'
end 
