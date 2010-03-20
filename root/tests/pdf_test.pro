pro pdf_test

  r1 = randomn(seed, 5d3) + 2
  r2 = randomn(seed, 5d3) - 2
  data = [r1, r2]
  
  x = findgen(100) / 10 - 5
  pdf1 = pdf(data, x, method = 'os')
  pdf2 = pdf(data, x, method = 'snr')
  pdf3 = pdf(data, x, method = 'srot')
  
  plot, x, pdf1, /nodata
  oplot, x, pdf1, color = fsc_color('blue')
  oplot, x, pdf2, color = fsc_color('red')
  oplot, x, pdf3, color = fsc_color('orange')
  oplot, x, .5 / sqrt(!dpi * 2) * (exp(-(x - 2)^2 / 2) + exp(-(x + 2)^2 / 2)), $
         color = fsc_color('green')
  
;  edf, data, ex, ey, /plot
;  oplot, x, total(pdf1,/cumul) / total(pdf1), color = fsc_color('blue')
;  oplot, x, total(pdf2,/cumul) / total(pdf2), color = fsc_color('red')
;  oplot, x, total(pdf3,/cumul) / total(pdf3), color = fsc_color('orange')

  

end
