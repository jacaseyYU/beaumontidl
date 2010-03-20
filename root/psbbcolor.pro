;+
; PURPOSE:
;  This function computes the AB colors of a blackbody observed in the
;  pan-starrs filter system.
;
; CATEGORY:
;  astronomy
;
; INPUTS:
;  temp: A scalar or vector of blackbody temperatures
; 
; OUTPUTS:
;  A [4, n_temp] array of colors. Each row contains (g-r, r-i, i-z,
;  z-y)
;
; PROCEDURE:
;  This function is a wrapper to synphot and blackbody. It uses the
;  pan-starrs filter transmission curves found on various internal
;  PanSTARRS pages.
;
; MODIFICATION HISTORY:
;  Feb 2010: Written by Chris Beaumont
;-
function psbbcolor, temp
  compile_opt idl2

  common psbbcolor, l,g,r,i,z,y
  if n_elements(l) eq 0 then begin
     ;- read in Pan-STARRS transmission curves
     readcol, '/home/beaumont/idl/data/transmission_curves/panstarrs.txt', $
              l, g, r, i, z, y, /silent, comment='#'
  endif

  nrow = n_elements(l)
  nobj = n_elements(temp)
  result = fltarr(4, nobj)
  lambda = l / 1d7              ;- nm to cm
  for j = 0L, nobj - 1 do begin
     flux = blackbody(temp[j], lambda, /wave, /cgs)
     magg = synphot(lambda, flux, g, /ab)
     magr = synphot(lambda, flux, r, /ab)
     magi = synphot(lambda, flux, i, /ab)
     magz = synphot(lambda, flux, z, /ab)
     magy = synphot(lambda, flux, y, /ab)
     result[0,j] = magg - magr
     result[1,j] = magr - magi
     result[2,j] = magi - magz
     result[3,j] = magz - magy
  endfor
  return, result
end
     
