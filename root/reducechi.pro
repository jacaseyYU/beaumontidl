pro reducechi

  files = file_search('/media/data/astrom/*.good.sav', count = ct)
  !p.multi = [0,1,2]
  for i = 0, ct - 1, 1 do begin
    
     restore, files[i], /verbose
     split = strsplit(files[i], '/', /extract)
     split = split[n_elements(split)-1]
     split = strsplit(split, '.', /extract)
     oldfile = file_search('/media/cave/catdir.bak/'+split[0]+'.bin.good.sav')
     
     chi = pos.chisq / pos.ndof
     rawchi = pos.chisq
     ndof = pos.ndof
     deltachi = pm.chisq / pm.ndof - chi
     h = histogram(chi, nbins = 100, min = 0, max = 10, loc = loc)
     peak = max(h, l)
     x = mags[2,*]

     restore, oldfile
     
     
     plot, loc, h, psym = 10, thick = 2, title = files[i], $
           xtit = 'Reduced Chi-Squared', ytit = 'N', charsize = 1.5
     oplot, [1, 1], [0, max(h) * 10], /line

     chi2 = pos.chisq / pos.ndof
     h = histogram(chi2, nbins = 100, min = 0.1, max = 10, loc = loc)
     oplot, loc, h, color = fsc_color('red'), thick = 2, psym = 10

     plot, x, chi, psym = 3, yra = [0, 5], $
            xtit = 'I Mag', ytit = 'Reduced Chi-Squared', charsize = 1.5, /nodata
     oplot, mags[2, *], chi2, psym = 3, color = fsc_color('red')
     oplot, x, chi, psym = 3

;     plot, x, deltachi, psym = 3, yra = [-1, 1]
;     h = histogram(deltachi, loc = loc, min = -100, max = 100, binsize = 1)
;     plot, loc, h, psym = 10, yra = [1, 1000], /ylog
;     oplot, -loc, h * (loc gt 0), color = fsc_color('red'), psym = 10
     stop
  endfor
  !p.multi = 0
end
