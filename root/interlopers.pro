;- how many interlopers for given observational parameters
pro interlopers

;-local luminosity function ref pts
;- from Gochanski et al 2009
Mr = [8,9,10,11,12,13,15,17]
phi = [.002, .0025, .004, .007, .006, .003, .002, .001] ;-.5 mag^-1 pc^-3
phi *= 2 ;- mag^-1 pc^-3
;- limiting magnitude
Mlo = 12
Mhi = 16
area = 1 ;- 1 sq degree view


;- expected nearby stars
Nexp = 0
Narr = fltarr(20)
m_test = findgen(20)/2 + 8
binsize = range(m_test) / n_elements(m_test) ;- mags bin^-1
phi_test = interpol(phi, Mr, m_test,/quadratic)
plot, m_test, phi_test
oplot, Mr, phi, psym = 4
oplot, m_test, phi_test, psym = 5
for i = 0, n_elements(m_test) - 1, 1 do begin
   dnear = 10 * 10^((Mlo - m_test[i])/5) ;-pc
   dfar = 10 * 10^((Mhi - m_test[i]) / 5) ;- pc
   volume = 4 * !pi / 3 * (dfar^3 - dnear^3) ;- pc^3 for whole sky
   volume *= area / (41252D) ;- pc^3 for my observing window
   Nexp += volume * phi_test[i] * binsize
   Narr[i] = volume * phi_test[i] * binsize
   print, m_test[i], dnear, dfar, Narr[i], $
          format='("M: ",f4.1, " D: ", i3, " - ", i4, " pc Nexp: ", i5)'   
endfor
print, Nexp
plot, m_test, Narr

return
;-scatter vs magnitude ref pts
Mr_scatt = [12, 16, 19, 20]
rms = [.03, .03, .25, .25]

end
