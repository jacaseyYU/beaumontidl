;+
; Convert mass to absolute visual magnitude, based on various
; relations
;-
function mass2magv, mass, age, filter = filter

if ~keyword_set(filter) then filter = 'v'
case filter of
   'v':
   'r':
   'i':
   'j':
   'k':
   'l':
   else: message, 'must choose filter among v,r,i,j,k,l'
endcase

result = mass * !values.d_nan

;- 4 mass ranges:
;  .01 -> .1 : DUSTY model grids
;  0.1 -> .5 : Linear interpolation between DUSTY and BaSTI
;  0.5 -> 10 : BaSTI model grids
;-
dustyrange = where(mass le .1, dct)
bastirange = where(mass ge .5, bct)
overlap = where(mass ge .1 and mass le .5, oct)

if dct ne 0 then begin
   dustymags = dustymag(mass[dustyrange], age[dustyrange], filter = filter)
   result[dustyrange] = dustymags
endif

if bct ne 0 then begin
   bastimags = bastimag(mass[bastirange], alog10(age[bastirange] * 1d9), $
                        filter = filter)
   result[bastirange] = bastimags
endif

if oct ne 0 then begin
   bastimags = bastimag(mass[overlap], alog10(age[overlap] * 1d9), $
                        filter = filter)
   dustymags = dustymag(mass[overlap], age[overlap], filter = filter)
   weight = (mass[overlap] - .1) / .4
   result[overlap] = bastimags * weight + dustymags * (1-weight)
endif

return, result

;-Malkov intermediate mass star relation
;-  2007MNRAS.382.1073M
;logmass = alog10(mass)
;hit = where(logmass gt -0.2 and logmass lt 1.5, ct)
;if ct ne 0 then $
;   result[hit] = 4.85 - 14.2 * logmass[hit] + 14.1 * logmass[hit]^2 - $
;                 9.99 * logmass[hit]^3 + 2.66 * logmass[hit]^4

;- Malkov 1997 low mass stellar relation
;masses = [.1, .2, .3, .4, .5, .6, .7]
;magvs = [14.68, 12.25, 11.27, 10.52, 9.65, 8.42, 7.64]
;hit = where(mass gt .1 and mass lt .7, ct)
;if ct gt 0 then $
;   result[hit] = interpol(magvs, masses, mass[hit])

;-low mass models from dusty
hit = where(mass le 0.1, ct)
if ct ne 0 then result[hit] = dustymag(mass[hit], age[hit])

return, result
end
