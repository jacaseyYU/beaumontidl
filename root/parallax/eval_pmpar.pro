pro eval_pmpar, jd, fit, ra, dec

sxaddpar, coords, 'crval1', float(fit.ra)
sxaddpar, coords, 'crval2', float(fit.dec)
sxaddpar, coords, 'crpix1', 1D
sxaddpar, coords, 'crpix2', 1D
sxaddpar, coords, 'cdelt1', 1/3600D
sxaddpar, coords, 'cdelt2', 1/3600D

name = tag_names(fit, /struct)
nopar = name eq 'PMFIT'

par_factor, fit.ra, fit.dec, jd, pR, pD

j2000 = 2451545.0D
time = (jd - j2000) / 365.25

adxy, coords, fit.ra, fit.dec, x0, y0
x = x0 + time * fit.ura  / 1000D 
y = y0 + time * fit.udec / 1000D 
if ~keyword_set(nopar) then begin
   x += fit.parallax / 1000D * pR
   y += fit.parallax / 1000D * pD
endif

ra = x
dec = y

for i = 0, n_elements(x) - 1, 1 do begin
   xyad, coords, x[i], y[i], r, d
   ra[i] = r
   dec[i] = d
endfor

return
;!!!!!!!
;- debugging code

x = ra
y = dec
if keyword_set(over) then begin
   oplot, x, y, color = fsc_color('orange')
endif else begin
   plot, x, y, xra = minmax(x), yra = minmax(y)
endelse
;!!!!!!!!!

end 

