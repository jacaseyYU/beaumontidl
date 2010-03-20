pro astrom_err_plot

  files = file_search('/media/cave/catdir.[1-9]*/*/*.skymodel', count = ct)
  
  for i = 0, ct - 1, 1 do begin
     restore, files[i]

     good = where(finite(skymodel_x[0,*]), gct)
     if gct eq 0 then begin
        print, 'No good skymodels for '+files[i]
        continue
     endif

     ;h1 = histogram(skymodel_x[0,good], loc = l1, nbins = 100)
     ;plot, l1, h1, psym = 10, charsize = 1.5
     ;stop

     plot, skymodel_x[1, good], skymodel_y[1,good], psym = 3
     x = arrgen(0, 10, .01)
     oplot, x, x
     stop

;     h1 = histogram(skymodel_x[1,good], loc = l1, nbins = 100)
;     plot, l1, h1, psym = 10, charsize = 1.5
;     h1 = histogram(skymodel_y[1,good], loc = l1, nbins = 100)
;     oplot, l1, h1, psym = 10, color = fsc_color('red')

  end

end
