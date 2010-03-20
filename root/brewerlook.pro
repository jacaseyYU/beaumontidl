pro brewerlook


for i = 0, 27 do begin
   ctload, i, /brewer
   set_plot,'ps'
   device, /color, /encap,file='brewer'+string(i,format='(i2.2)')+'.eps', $
           bits_per_pixel = 8
   tvimage, bytscl(dist(256)),/keep
   xyouts, .5, .5, strtrim(i,2), charsize = 2, charthick = 2, /norm, align = .5
   ;colorbar, pos = [pos[0], pos[3]+.05, pos[2], pos[3]+.15]
   device, /close
endfor

set_plot, 'x'

end
