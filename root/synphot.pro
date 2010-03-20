;+
; PURPOSE:
;  This function calculates the photometric magnitude of an object,
;  given its SED.
;
; CATEGORY:
;  Astrophysics
;
; INPUTS:
;  lambda: Vector of wavelengths of the sed. Any units are fine.
;  flux: The sed. Must be in cgs units for AB mags to be correct
;  transmission: A vector giving the fractional system throughput at
;                each wavelength. 
;
; KEYWORD PARAMETERS:
;  f0: The sed of the object defined to be the zero-th magnitude
;  ab: Set to report fluxes in the AB magnitude system.
;
; OUTPUTS:
;  The synthetic magnitude of the object
;
; PROCEDURE:
;  If /AB is set, than the AB zero point is used. If not set and f0 is
;  not provided, then the magnitude zero point is based on a constant
;  SED of F_lambda = 1 (cgs)
;
;  Magnitude is calculated as
;    mag = integral( lambda * flux * throughput) / 
;          integral( lambda * f0 * throughput)
;
; MODIFICATION HISTORY:
;  December 2009: Written by Chris Beaumont
;-
function synphot, lambda, flux, transmission, $
                  ab = ab, $
                  f0 = f0
  compile_opt idl2

  ;- check inputs
  if n_params() ne 3 then begin
     print, 'synphot calling sequence:'
     print, '    mag = synphot(lambda, flux,'
     print, '          [transmission = transmission, f0 = f0, /ab])'
     return, !values.f_nan
  endif

  num = n_elements(lambda)
  if num ne n_elements(flux) then $
     message, 'flux mas have the same length as lambda'
  
  if keyword_set(ab) then begin
     f0 = 1.08848d-9 / lambda^2 ;- sed of an AB 0 mag star
  endif else if ~keyword_set(f0) then begin
     f0 = lambda * 0 + 1
  endif else if n_elements(f0) ne num then $
     message, 'f0 must have the same length as lambda'

  if n_elements(transmission) ne num then $
     message, 'transmission must have the same length as lambda'


  ;- do the calculation
  result = int_tabulated(lambda, flux * transmission * lambda) / $
           int_tabulated(lambda, f0 * transmission * lambda)
  return, -2.5 * alog10(result)

end
