
pro ipp_nastrom_stats, out= out

fields = ['92', '95', '98','101','107', '110', '113']

if keyword_set(out) then begin
   set_plot,'ps'
   device, /land, /color, file='nastrom.ps'
   col = fsc_color('black')
   background = fsc_color('white')
endif else begin
   window, 0, retain = 2
   col = fsc_color('white')
   background = fsc_color('black')
endelse

plot, [0,100], [0, 1.0], /nodata, $
      xtit = 'Number of astrometry stars / chip', $
      ytit = 'P(Nastrom > x)', charsize = 1.5, color = col, $
      background = background
colors = ['green', 'red', 'blue', 'orange', 'purple', 'yellow', 'plum']

;-part 1 : Nastrom cdf

for i = 0, n_elements(fields)-1, 1 do begin
   readcol, 'sa.'+fields[i]+'.nastrom', $
            a, b, c, error, d, e, num, $
            format = 'a,a,a,f,a,a,i', delimiter=' ', /silent
   
   h = histogram(num, loc=loc, binsize = 1, min = 0)
   t = total(h, /cumulative)
   oplot, loc, 1.0 - 1.0 * t / total(h), color = fsc_color(colors[i]), thick = 2
  
   xyouts, .8, .8 - .05 * i, fields[i], /norm, $
           charsize = 1.5, color=fsc_color(colors[i])

endfor

;- part 2 : scatter cdf

if keyword_set(out) then begin
   device,/close
   device, /land, /color, file='scatter.ps'
endif else begin
   window, 1, retain = 2
endelse

plot, [0, .4], [0, 1.0], /nodata, $
      xtit = 'scatter (arcsec)', $
      ytit = 'P(scatter > x)', charsize = 1.5, $
      color = col, background = background

for i = 0, n_elements(fields) -1 , 1 do begin
   readcol, 'sa.'+fields[i]+'.nastrom', $
            a, b, c, error, d, e, num, $
            format = 'a,a,a,f,a,a,i', delimiter=' ', /silent
   
   h = histogram(error, loc = loc, binsize = .005, min = 0)
   t = total(h, /cumulative)
   oplot, loc, 1 - 1.0 * t / total(h), color = fsc_color(colors[i]), thick = 2
endfor

if keyword_set(out) then begin
   device,/close
   set_plot,'X'
endif

;-part 3 : scatter vs nastrom

;!!!!!
;- doesnt look like much
return
;-!!!!!

window, 2, retain = 2
plot, [0, 100], [0, .4], /nodata, $
      xtit ='Nastrom', $
      ytit = 'Scatter (arcsec)'

for i = 0, n_elements(fields) - 1, 1 do begin
   readcol, 'sa.'+fields[i]+'.nastrom', $
            a, b, c, error, d, e, num, $
            format = 'a,a,a,f,a,a,i', delimiter=' ', /silent
   oplot, num, error, color = fsc_color(colors[i]), psym = symcat(16)
endfor

end   
;- throughput stats
; sa 92  (50% to smf, 60% of chips)
; sa 95  (75% to smf, 80% of chips)
; sa 98  (97% to smf, 98% of chips)
; sa 101 (80% to smf, 85% of chips)
; sa 107 (80% to smf, 97% of chips)
; sa 110 (86% to smf, 83% of chips)
; sa 113 (98% to smf, 97% of chips)
