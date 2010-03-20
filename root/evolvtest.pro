pro evolvtest

ages = [.001, .01, .1, 1, 5, 50]

masses = findgen(1d3) / 1d2
for i = 0, n_elements(ages) -1,1  do begin
   magr = mass2mag(masses, masses*0+ages[i], filter='r')
   magi = mass2mag(masses, masses*0+ages[i], filter='i')
   magv = mass2mag(masses, masses*0+ages[i], filter='v')
   magm = mass2mag(masses, masses*0+ages[i],/malkov)
   live = where((masses^(-2.5) * 10) gt ages[i], lct)
   plot, masses, magv, /xlog, xra = [1d-2, 1d1], yra = [-5, 40]
   oplot, masses, magv, color = fsc_color('green')
   oplot, masses, magr, color = fsc_color('red')
   oplot, masses, magi, color = fsc_color('brown')
   oplot, masses[live], magm[live], color = fsc_color('blue')
   oplot, [.1, .1], [-80, 80]
   oplot, [.5, .5], [-80, 80]
   stop   
endfor

end
