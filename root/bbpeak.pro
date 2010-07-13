;+
; PURPOSE:
;  This function returns the peak wavelengths (in meters) of
;  blackbody spectra (B_lambda) at a set of requested
;  temperatures. Note that, due to the symmetry of Wein's
;  displacement law, the function will alternately return the
;  temperature (in K) associated with an input peak temperature (in
;  m).
;
; INPUTS:
;  temperature: A set of temperatures (in K), or a set of wavelengths
;  (in m);
;
; OUTPUTS:
;  The peak wavelengths associated with the input temperatures, or
;  vice versa.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function bbpeak, temperature
  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, 'result = bbpeak(temp or wavelength (meters))'
     return, !values.f_nan
  endif

 b = 2.8977685d-3
 return, b / temperature

end
