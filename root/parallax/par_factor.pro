;+
; PURPOSE:
;  This procedure calculates the parallactic factors for an object as
;  a function of the observation time and celestial location. The
;  parallactic factors pR and pD obey the relation
;   ra  =  ra_0 + u_ra  * (t - t0) + pi * pR
;   dec = dec_0 + u_dec * (t - t0) + pi * pD
;
; CALLING SEQUENCE:
;  par_factor, ra, dec, jd, pR, pD
;
; INPUTS:
;   ra: The right ascension, in J2000 degrees
;  dec: The declination, in J2000 degrees
;   jd: One or more julian dates
;
; OUTPUTS:
;  pR: RA parallactic factor corresponding to each jd
;  pD: Dec parallactic factor corresponding to each jd
;
; MODIFICATION HISTORY:
;  March 2009: Written by Chris Beaumont
;-
pro par_factor, ra, dec, jd, pR, pD
compile_opt idl2

;- check arguments
if n_params() ne 5 then begin
   print, 'calling sequence: '
   print, 'par_factor, ra, dec, jd, pR, pD'
   return
endif

if size(ra, /n_d) ne 0 || size(dec, /n_d) ne 0 then $
   message, 'ra and dec must be scalars'

if ~arg_present(pR) || ~arg_present(pD) then $
   message, 'must supply named variables to hold pR and pD'

;- guess whether or not the jd is in the proper form
if (min(jd) lt 2400000) then $
   message, /continue, 'WARNING: jd appears to be a reduced julian date'

sun_ecliptic, jd, l, b, e, /radian
r_ra = ra * !dtor
r_dec = dec * !dtor
pR =  (cos(e) * sin(l) * cos(r_ra) - cos(l) * sin(r_ra))
pD = -(cos(e) * sin(l) * sin(r_ra) + cos(l) * cos(r_ra)) * sin(r_dec) + $
     sin(e) * sin(l) * cos(r_dec)

return

end
