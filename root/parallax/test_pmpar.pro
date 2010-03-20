pro test_pmpar

;-measurements of sources in Orion, from 
;-arXiv 0706.2361

juldate, [2003,1,29], jd0
juldate, [2003,12,22], jd1
juldate, [2004, 6, 12], jd2
juldate, [2004, 10, 15], jd3
juldate, [2004, 12, 11], jd4

;-GMR A
ra = [ten(5,35,11.80269059D), $
      ten(5, 35, 11.80289569D), $
      ten(5, 35, 11.80297711D), $
      ten(5, 35, 11.80317743), $
      ten(5, 35, 11.80305485D)] * 15D
;raerr = [14.84, 29.89, 36.82, 50.88, 11.47] * 1D-6 / 3600D
raerr = fltarr(5) + .17 * 1D-3 / 3600
dec = [ten(-5, 21, 49.246612), $
       ten(-5, 21, 49.247830), $
       ten(-5, 21, 49.246546), $
       ten(-5, 21, 49.249019), $
       ten(-5, 21, 49.249859)]
;decerr = [36.48, 93.57, 86.22, 163.29, 21.66] * 1D-6 / 3600D
decerr = raerr * 2.5
dates = [jd0, jd1, jd2, jd3, jd4] + 2400000D

fit = fit_pmpar(dates, ra, dec, raerr, decerr, clip = 1)
plot_pmpar, ra, dec, raerr, decerr, dates, fit

print, fit.chisq

end
