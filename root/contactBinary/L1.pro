;+
; PURPOSE:
;  This function gives the location of the inner Lagrangian (L1)
;  point as a function of q, the ratio of secondary to primary mass.
;
; CATEGORY:
;  Three body problem
;
; CALLING SEQUENCE:
;  result = L1(q)
;
; INPUTS:
;  q: The ratio of secondary to primary mass.
;
; OUTPUTS:
;  The location of the L1 Lagrange point. This is the distance, in
;  units of the primary-secondary separation, measured from the
;  system's center of mass. The secondary mass lies along the
;  positive x axis.
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, Feb 2009
;-
function L1, q

compile_opt idl2
on_error, 2

;- check inputs
if n_params() ne 1 then begin
   print, 'L1 calling sequence: '
   print, 'result = L_1(q)'
   print, 'q: Msecondary / Mprimary'
   return, !values.f_nan
endif

if q gt 1  || q le 0 then $
   message, 'q must fall in the range (0,1]'

dq = double(q)
acc = 1d-4        ;- precision to determine L1 to
mu2 = dq / (1 + dq) ;- m2
mu1 = 1 - mu2     ;- m1


;- The distance from the secondary to the L1 point 
;  is the root of the equation
;  mu2 / mu1 - 3 * x^3 * (1 - x + x^2 / 3) / 
;  ( (1 + x + x^2) * (1 - x)^3 )

xlo = -mu2
xhi = mu1
x = (xlo + xhi) / 2D

;- binary search
while (xhi - xlo) gt acc do begin
   delt = mu2 / mu1 - 3 * x^3 * (1 - x + x^2 / 3) / $
          ( (1 + x + x^2) * (1 - x)^3 )
   if delt lt 0 then xhi = x else xlo = x
   x = (xhi + xlo) / 2D
endwhile

return, mu1 - x

end
