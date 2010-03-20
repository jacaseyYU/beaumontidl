;+
; PURPOSE:
;  This function interpolates between several stellar evolution models
;  to convert a set of stellar masses and ages to absolute magnitudes.
;
; CATEGORY:
;  astrophysics
;
; INPUTS:
;  mass: masses, in solar masses. Scalar or vector
;  age:  Ages, in Gyr. Scalar or vector
;
; KEYWORD PARAMETERS:
;  filter: One of 'v, r, i, z, j, h, k'. Which filter to compute an
;  absolute magnitude for
;
; OUTPUTS:
;  The magnitude corresponding to the requested mass, age, and filter
;
; PROCEDURE:
;  mass2mag is a wrapper routine to several procedures which
;  interpolate between grids of stellar evolution. Models include:
;   -The DUSTY models, used for .01 < M/Msolar < .1
;   -The Baraffe models, used for .1 < M/Msolar < .5
;   -The BaSTI models, used for .5 < M/Msolar < 10
;
; RESTRICTIONS:
;  If the requested parameters lie outside of the model grids, NAN is
;  returned
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;  November 2009: Documentation, error handling added
;-
function mass2mag, mass, age, filter = filter, ages = ages
  compile_opt idl2

  ;- check inputs
  if n_params() ne 2 && ~keyword_set(ages) then begin
     print, 'calling sequence:'
     print, ' result = mass2mag(mass, age, [filter = filter]'
     print, '          mass in Msolar. age in Gyr'
     return, !values.f_nan
  endif

  if keyword_set(ages) then age = ages
  sz = n_elements(mass)
  if n_elements(age) ne sz then message, 'mass and age vectors do not have the same length'
  
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
  
  result = mass * !values.d_nan

  ;- 3 mass ranges:
  ;  .01 -> .1 : DUSTY model grids
  ;   .1 -> .5 : Baraffe models
  ;  0.5 -> 10 : BaSTI model grids

  dustyrange = where(mass le .1, dct)
  bastirange = where(mass ge .5, bct)
  barafferange = where(mass ge .1 and mass le .5, barct)
  
  if dct ne 0 then begin
     dustymags = dustymag(mass[dustyrange], age[dustyrange], filter = filter)
     result[dustyrange] = dustymags
  endif
  
  ;-XXX currently not used - only have information for V band
  if keyword_set(malkov) then begin
     logmass = alog10(mass)
     hit = where(logmass gt -0.2 and logmass lt 1.5, ct)
     if ct ne 0 then $
        result[hit] = 4.85 - 14.2 * logmass[hit] + 14.1 * logmass[hit]^2 - $
                      9.99 * logmass[hit]^3 + 2.66 * logmass[hit]^4
     
                                ;- Malkov 1997 low mass stellar relation
     masses = [.1, .2, .3, .4, .5, .6, .7]
     magvs = [14.68, 12.25, 11.27, 10.52, 9.65, 8.42, 7.64]
     hit = where(mass gt .1 and mass lt .7, ct)
     if ct gt 0 then $
        result[hit] = interpol(magvs, masses, mass[hit])
     return, result
  endif
  
  if bct ne 0 then begin
     bastimags = bastimag(mass[bastirange], alog10(age[bastirange] * 1d9), $
                          filter = filter)
     result[bastirange] = bastimags
  endif
  
  if barct ne 0 then begin
     result[barafferange] = baraffemag(mass[barafferange], $
                                       age[barafferange], $
                                       filter = filter)
  endif
  
  bad = where(mass le .01 or mass ge 10, badct)
  if (badct ne 0) then result[bad] = !values.f_nan
  return, result
end
