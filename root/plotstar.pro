pro plotstar, x, y, mag, magrange = magrange, _extra = extra, starcolor = starcolor, over = over

  if n_params() ne 3 then begin
     print, 'plotstar calling sequence:'
     print, 'plotstar, x, y, mag, [magrange = magrange, starcolor = starcolro, /over]'
     return
  endif


nstar = n_elements(x)

if ~keyword_set(magrange) then magrange = minmax(mag, /nan)
if n_elements(starcolor) eq 1 then starcolor = replicate(starcolor, nstar)

;- set up plot window
if ~keyword_set(over) then $
   plot, x, y, /nodata, xra = minmax(x), yra = minmax(y), /xsty, /ysty, _extra = extra

psym = symcat(16)

;- individually plot stars
sz = [.2, 3] ;- range of symsizes
magscale = magrange[0] > mag < magrange[1]
magscale = sz[1] - (magscale - magrange[0]) / range(magrange) * (sz[1] - sz[0])
for i = 0, nstar - 1, 1 do begin
   if keyword_set(starcolor) then $ 
      oplot, [x[i]], [y[i]], psym = psym, symsize = magscale[i], color = starcolor[i] $
   else $
      oplot, [x[i]], [y[i]], psym = psym, symsize = magscale[i]
endfor

end
