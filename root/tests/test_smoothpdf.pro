pro test_smoothpdf

for i = 0, 2, 1 do begin
   m = randomn(seed, 1d4)
   x = findgen(100)/10 - 5
   pdf = smoothpdf(m, x, n = 5, /debug)
   plot, x, pdf
   pdf = smoothpdf(m, x, n = 10, /debug)
   oplot, x, pdf, color = fsc_color('red')
   pdf = smoothpdf(m, x, n = 20, /debug)
   oplot, x, pdf, color = fsc_color('orange')
   pdf = smoothpdf(m, x, n = 50, /debug)
   oplot, x, pdf, color = fsc_color('yellow')
   pdf = smoothpdf(m, x, n = 100, /debug)
   oplot, x, pdf, color = fsc_color('pink')
   pdf = smoothpdf(m, x, n = 200, /debug)
   oplot, x, pdf, color = fsc_color('green')
   pdf = smoothpdf(m, x, n = 500, /debug)
   oplot, x, pdf, color = fsc_color('purple')
   pdf = smoothpdf(m, x, n = 1000, /debug)
   oplot, x, pdf, color = fsc_color('blue')
   pdf = smoothpdf(m, x, n = 2000, /debug)
   oplot, x, pdf, color = fsc_color('brown')
   pdf = smoothpdf(m, x, n = 5000, /debug)
endfor


end
