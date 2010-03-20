pro flag_nmeasure_corr
  
  m = mrdfits('/media/cave/catdir.98/n0000/0148.cpm', 1, h, range = [1, 1d7])
  t = mrdfits('/media/cave/catdir.98/n0000/0148.cpt', 1, h)

  nm = t[m.ave_ref].nmeasure

  flags = 2UL^lindgen(32)
;  flags[0] = 144728
  for i = 0, n_elements(flags) - 1, 1 do begin
     print, flags[i], format='(z)'
     hit = where((m.phot_flags and flags[i]) ne 0, hitct, complement = miss, ncomp = nmiss)

     plot, minmax(nm), [1, 1d6], /ylog, /nodata

     if hitct ne 0 then begin
        h = histogram(nm[hit], loc = loc, nbins = 20)
        oplot, loc, h, psym = 10
     endif
    
     if nmiss ne 0 then begin
        h = histogram(nm[miss], loc = loc, nbins = 20)
        oplot, loc, h, psym = 10, color = fsc_color('red')
     endif
     stop
  endfor

end
