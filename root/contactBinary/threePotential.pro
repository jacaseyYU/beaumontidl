;+
; PURPOSE:
;  This function returns the three body pseudo-potential function for
;  a set of points in the three body frame. The surfaces of binary stars
;  correspond to surfaces of constant potential.
;
; CATEGORY:
;  Three body problem
;
; CALLING SEQUENCE:
;  result = threePotential(q, x, y, z)
;
; INPUTS:
;  q: Ratio of secondary mass to primary mass
;  x: X coordinates (the axis joining the two bodies)
;  y: Y coordinates (Perpendicular to x, in the orbital plane)
;  z: Z coordinates (Perpendicular to orbital plane)
;
; OUTPUTS:
;  result: The potential corresponding to the points (x,y,z)
;
; EXAMPLE:
;  The following statements draw the roche-lobes of a double-contact
;  binary, with mass ratio q = .25
;  IDL> q = .25
;  IDL> ind = findgen(1000) / 999. * 3 - 1.5
;  IDL> x = rebin(ind, 1000, 1000)
;  IDL> y = rebin(1 # ind, 1000, 1000)
;  IDL> z = 0 * x
;  IDL> Uref = threePotential(q, L1(q), 0, 0)
;  IDL> U = threePotential(q, x, y, z)
;  IDL> contour, u, lev = Uref
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont Feb 2009
;-
FUNCTION threePotential, q, x, y, z

compile_opt idl2
on_error, 2

;- check inputs
if n_params() ne 4 then begin
   print, 'threePotential calling sequence:'
   print, 'result = threePotential(q, x, y, z)'
   return, -1
endif

if n_elements(q) ne 1 then $
   message, 'q must be a scalar'

if (q lt 0 || q gt 1) then $
   message, 'q must be in the range [0,1]'

sz = n_elements(x)
if n_elements(y) ne sz || n_elements(z) ne sz then $
   message, 'x, y, and z must have the same number of elements'

;- perform calculation
mu2 = q / (1 + q)
mu1 = 1 - mu2

return, 0.5D * (x^2 + y^2) + $
        mu1 / sqrt( (x + mu2) ^ 2 + y^2 + z^2) + $
        mu2 / sqrt( (x - mu1) ^ 2 + y^2 + z^2)

end
