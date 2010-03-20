pro besancon_test

  data1 = read_besancon('~/parallax_papers/besancon/control.2.txt')
  data2 = read_besancon('~/parallax_papers/besancon/control.txt')
  
  !p.multi = [0,2,2]
  plot, data1.gr, -(data1.mv -data1.gr), psym = 3, $
        xtit = 'G - R', ytit = 'R'
  oplot, data2.gr, -(data2.mv - data2.gr), color = fsc_color('green'), psym = 3

  plot, data1.ri, -(data1.mv -data1.gr), psym = 3, $
        xtit = 'R - I', ytit = 'R'
  oplot, data2.ri,  -(data2.mv - data2.gr), color = fsc_color('green'), psym = 3

  plot, data1.iz, -(data1.mv -data1.gr), psym = 3, $
        xtit = 'I - Z', ytit = 'R'
  oplot, data2.iz,  -(data2.mv - data2.gr), color = fsc_color('green'), psym = 3



!p.multi = 0
;  plot, -data1.gr, data1.u - data1.ug, psym = 3
;  oplot, data2.gr, data2.u - data2.ug,  psym = 3, color = fsc_color('green')

end
