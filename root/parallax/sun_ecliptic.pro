;+
; PURPOSE:
;  This procedure returns the ecliptic position of the sun at a given
;  julian date. The equations are taken from section C of the
;  Astronomical Almanac.
;
; CALLING SEQUENCE:
;  sun_ecliptic, jd, lambda, beta, epsilon, [/radians]
;
; INPUTS:
;  jd: One or more julian dates.
;
; OUTPUTS:
;  lambda: The ecliptic longitude of the sun, in degrees by default.
;  beta: The ecliptic latitude of the sun, in degrees by default.
;  epsilon: The obliquity of the ecliptic, in degrees by default.
;
; KEYWORD PARAMETERS:
;  radians: If set, the values for lambda, beta, and epsilon are
;  output in radians.
;
; RESTRICTIONS:
;  These are low precision formulae, accurate to within a degree for
;  within the time range 1950-2050
;
; MODIFICATION HISTORY:
;  March 2009: Written by Chris Beaumont
;-
pro sun_ecliptic, jd, lambda, beta, epsilon, radian = radian

;- check parameters
if n_params() ne 4 then begin
   print, 'calling sequence:'
   print, 'sun_ecliptic, jd, lambda, beta, epsilon'
   return
endif

if ~arg_present(lambda) || $
   ~arg_present(beta) || $
   ~arg_present(epsilon) then begin
   message, 'must supply named variables to hold lambda, beta, and epsilon' 
endif

j2000 = 2451545.0D
n = jd - J2000
L = 280.460D + 0.9856474D * n
g = (357.528D + 0.9856003D * n) * !dtor

lambda = L + 1.915D * sin(g) + 0.020 * sin(2. * g)
beta = lambda * 0.0D
epsilon = (23.439 - 0.0000004 * n)

lambda = wrap(lambda, 360D)
beta = wrap(beta, 360D)
epsilon = wrap(epsilon, 360D)

if keyword_set(radian) then begin
   lambda  *= !dtor
   beta    *= !dtor
   epsilon *= !dtor
endif

return
end
