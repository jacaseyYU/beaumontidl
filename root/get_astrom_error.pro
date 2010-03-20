;+
; PURPOSE:
;  This procedure emulates the Ohana procedure GetAstromError.c. It
;  estimates the astrometric error for an entry in a .cpm dvo table.
;
; CATEGORY:
;  Astrometry, dvo
;
; CALLING SEQUENCE:
;  get_astrom_error, m, p, dra, ddec
;
; INPUTS: 
;  m: One or more .cpm entry structures describing the measurements
;     for which to estimate errors.
;  p: The photcodes structure
;
; OUTPUTS:
;  dra: the error in right ascension, in degrees
;  ddec: the error in declination, in degrees 
;
; MODIFICATION HISTORY:
;  Lifted from Ohana on March 2009 by Chris Beaumont
;-
pro get_astrom_error, m, p, dra, ddec

;-check inputs
if n_params() ne 4 then begin
   print, 'get_astrom_error calling sequence:'
   print, 'get_astrom_error, m, p, dra, ddec'
   return
end

if ~arg_present(dra) || ~arg_present(ddec) then begin
   message, 'dra and/or ddec were not passed by reference'
endif

;-calculate errors
code  = p[m.photcode]                               
AS    = code.astrom_Err_Scale     ;-set to zero in current photcode tables 
MS    = code.astrom_Err_Mag_Scale
dPsys = code.astrom_Err_Sys
dM    = m.mag_err
min_error = .001  

dra  = m.x_ccd_err
ddec = m.y_ccd_err
dra  = sqrt(dPsys^2 + AS * dra^2 + MS * dM^2) > MIN_ERROR
ddec = sqrt(dPsys^2 + AS * ddec^2 + MS * dM^2) > MIN_ERROR

dra /= 3600D
ddec /= 3600D

end
