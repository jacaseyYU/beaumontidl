;+
; PURPOSE:
;  Convert a given magnitude and age to a stellar mass, by
;  interpreting between stellar evolution models
;
; CATEGORY:
;  astrophysics
;
; INPUTS:
;  mag: A scalar or vector of magnitudes
;  age: A scalar or vector of ages, in Gyr
;
; KEYWORD PARAMETERS:
;  filter: One of 'v,r,i,z,j,h,k'. Defaults to 'v'
;
; OUTPUTS:
;  The approximate mass of the specified magnitudes and ages.
;
; PROCEDURE:
;  This is a wrapper which executes a binary search on the function
;  mass2mag. See documentation of that procedure for information on
;  the model interpolation.
;
; MODIFICATION HISTORY:
;  November 2009: Written by Chris Beaumont
;-
function mag2mass, mag, age, filter = filter

  sz = n_elements(mag)

  if ~keyword_set(filter) then filter = 'v'
  case filter of
     'v':
     'r':
     'i':
     'z':
     'j':
     'h':
     'k':
     else: message, 'must choose filter among v,r,i,z,j,h,k'
  endcase


  ;- simple binary search for best value
  mass = arrgen(.01, 10, nstep = 10, /log)
  result = fltarr(sz) * !values.f_nan
  for i = 0, sz - 1, 1 do begin
     tmag = mass2mag(mass, replicate(age[i], n_elements(mass)), filter = filter)
     neg = where(tmag lt mag[i], ct1)
     pos = where(tmag gt mag[i], ct2)
     if ct1 eq 0 || ct2 eq 0 then continue
     result[i] = bsearch('mass2mag', mass[min(neg)], mass[max(pos)], mag[i], $
                         yprecision = 1d-2, ages = age[i], filter = filter)
  endfor
  return, result
end
