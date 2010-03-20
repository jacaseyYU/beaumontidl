;+
; NAME:
;  analyze
;
; DESCRIPTION:
;  Analyzes the .dat files created in trends
;-

pro analyze
compile_opt idl2

restore, file='dat.sav'
!p.multi = [0, 1, 2]
set_plot, 'ps'
device, /color, file = 'analyze.ps', xsize = 10, ysize = 7.5, $
        /in, /land

loadct, 38, /silent
black = fsc_color('black', 255)
white = fsc_color('white', 0)


plot, [0, .3], [0, 500], color = black, /nodata, $
      xtitle = 'Astrometric Scatter (arcsec)', $
      ytitle = 'Number of objects', charsize = 1

for i = 0, 11, 1 do begin

    color = ((i+1)/ 12.) * 255
    success = execute('tmp = dat'+strtrim(string(i),2))

    if (success eq 0) then stop

    h = histogram(tmp, loc = loc, binsize = .01,/nan, min = 0, max = 2)
    oplot, loc, 1.0 * h , color = color
    xyouts, 0.25, 450 - 20 * i, 'Iteration '+strtrim(string(i),2),$
            /data, color = color
endfor


;- mean/median magnitude binned sample
avg = fltarr(7)
err = fltarr(7)

plot, [11.5, 18.5], [0.05, .3], /nodata, color = black, $
  xtitle = 'Magnitude', ytitle = 'Scatter (arcsec)', charsize = 1, /xsty

for i = 0, 11, 1 do begin
    color = (i + 1) / 12. * 255;
    success = execute('tmp = dat'+strtrim(string(i),2))
    if (success eq 0) then stop
    for j = 12, 18, 1 do begin
        ind = where(abs(tmp[0,*] - j) lt .5)
        avg[j - 12] = mean( sigclip(tmp[1,ind]), /nan )
    endfor
    oplot, findgen(7) + 12, avg, color = color
endfor

device,/close
set_plot, 'X'
!p.multi = 0

end
