pro skychi

  files = file_search('/media/cave/catdir.*/*/*skymodel', count = ct)

  for i = 0, ct - 1, 1 do begin

     restore, files[i]                      
     good = where(finite(chix), chict)
     if chict eq 0 then continue
     chix = chix[good]  & chiy = chiy[good]
     h1 = histogram(chix, min = 0, max = 10, binsize = .5, loc = loc1)
     h2 = histogram(chiy, min = 0.1, max = 10, binsize = .5, loc = loc2)
     plot, loc1, h1, $
           psym = 10, thick = 2, yra = minmax([h1,h2])
     oplot, loc2, h2, psym = 10, color = fsc_color('red'), thick = 2
     oplot, [1,1], minmax(h1) * 10, /line
     print, total(h1), total(h2)
     stop
  endfor

end
