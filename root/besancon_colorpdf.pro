;++
;  Need to compute rho(disk) / rho(bulge) as a function of (l,b,d).
;
;  Need the R band luminosity function for WDs
;   gaussian with mu = 16.8, sigma = 0.55
;
; Ignoring giants for now. Let's see what happens when we apply
; the method to the GP field, with many giants. 
;-
pro besancon_colorpdf

  file = '~/parallax_papers/besancon/control.txt'

  data = read_besancon(file)

  num = n_elements(data)
  r1 = randomn(seed, num) / 15.
  r2 = randomn(seed, num) / 15.

  u = data.u - 5 * alog10(data.dist / .01)
  r = u - data.ug - data.gr + r2


;  halo = where(data.age eq 9 and data.cl eq 6)
;  h = histogram(r[halo], loc = loc, nbins = 200)
;  plot, loc, h, psym = 10
;  fit = gaussfit(loc, h, a, nter = 3)
;  oplot, loc, fit
;  print, a
;  return

  yra = reverse(minmax(r))
  ;- map 1: P(G-R | R)
  plot, data.gr + r1, r, psym = 3, pos = [.05, .05, .45, .45], yra = yra, $
        xtit = 'G-R'
  x = [.25, .25, 1.25, 1.25, 1.9]
  y = [0, 5, 10, 15, 20]
  oplot, x, y, color = fsc_color('red'), thick = 3

  x = [-.4, .9, -.4]
  y = [11, 16.5, 19.5]
  oplot, x, y, color = fsc_color('orange'), thick = 3

  x = [1, .85]
  y = [18.2, 19.7]
  oplot, x, y, color = fsc_color('purple'), thick = 3

;  halo = where(data.age eq 9 and data.cl eq 6)
;  wd = where(data.cl eq 6 and data.age ne 9)
;  oplot, data[halo].gr + r1, r[halo], psym = 3, color = fsc_color('blue')
;  oplot, data[wd].gr + r1, r[wd], psym = 3, color = fsc_color('green')
;  return

  ;- map 2: P(R-I | R)
  plot, data.ri + r1, r, psym = 3, pos = [.05, .5, .45, .95], yra = yra, $
        xtit = 'R-I', /noerase

  x = [0.3, .1, 0.7, 1.85, 3]
  y = [0, 5, 10, 15, 20]
  oplot, x, y, color = fsc_color('red'), thick = 3

  x = [-0.5, 0.5, -1]
  y = [11, 16.5, 19.5]
  oplot, x, y, color = fsc_color('orange'), thick = 3


  x = [-1, -3]
  y = [18.2, 19.7]
  oplot, x,y, color = fsc_color('purple'), thick = 3

  ;- map3: P(I - Z | R)
  plot, data.iz + r1, r, psym =3, pos = [.5, .05, .95, .45], yra = yra, $
        xtit = 'I-Z', /noerase

  x = [.1, 0, .3, .8, 1.2]
  y = [0, 5, 10, 15, 20]
  oplot, x, y, color = fsc_color('red'), thick = 3
  
  x = [-.3, .3, -.6]  
  y = [11, 16.5, 19.5]
  oplot, x, y, color = fsc_color('orange'), thick = 3


  x = [-0.7, -1.8]
  y = [18.2, 19.7]
  oplot, x, y, color = fsc_color('purple'), thick = 3

  ;- map4: P(U-G | R)
  plot, data.ug + r1, r, psym =3, pos = [.5, .5, .95, .95], yra = yra, $
        xtit = 'U-G', /noerase

  x = [1.5, .8, 2.1, 3, 5.5]
  y = [0, 5, 10, 15, 20]
  oplot, x, y, color = fsc_color('red'), thick = 3

end
