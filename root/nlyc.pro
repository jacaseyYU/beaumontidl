;+
; PURPOSE:
;  This function approximates the ionizing photon rate from an HII
;  region using its observed radio luminosity. The forumula comes
;  from http://www.cv.nrao.edu/course/astr534/FreeFreeEmission.html,
;  equation 4B7
;
; CATEGORY:
;  Radio Astronomy
;
; CALLING SEQUENCE:
;  NLyc = nlyc(Te, nu, L)
;
; INPUT:
;  Te: The electron temperature (~1d4 for HII regions, 1d6 for hot
;      ionized medium)
;  nu: The frequency of the radio observation, in GHz
;   L: The luminoxity at frequency nu, in W Hz^-1
;
; OUTPUT:
;  The ionizing photon rate
;
; MODIFICATION HISTORY:
;  April 2009- Written by Chris Beaumont
;-
function nlyc, Te, nu, L
compile_opt idl2
on_error, 2

;- check inputs
if n_params() ne 3 then begin
   print,'nlyc calling sequence'
   print,'Nlyc = nlyc(Te, nu [GHz], L [W Hz-1])'
   return, -1
endif
sz = n_elements(Te)
if n_elements(nu) ne sz || n_elements(L) ne sz then $
   message, 'Te, nu, and L must contain the same number of elements'

;-the equation
return, 6.3d52 * (Te / 1d4)^(-0.45) * (nu)^0.1 * (L / 1d20)
end
