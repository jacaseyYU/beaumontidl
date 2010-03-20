;+
; PURPOSE: 
;  This procedure characterizes the shapes of tidally
;  distorted binary stars. For a given binary component (primary /
;  secondary) It determines the radii of the smallest sphere
;  completely outside the star, and the biggest sphere completely
;  inside the star. Both spheres are centered on the star. This is
;  useful for eclipse testing, since any line of sight which falls
;  within the small sphere is certainly eclipsed, while any LOS which
;  falls outside the big sphere certainly isn't.
;-

; private functions
function threeP_z, z
  compile_opt idl2, hidden
  common limitingSquaresBlock, q, u, xcen
  return, (threePotential(q, xcen, 0, z) - u)^2
end

function threeP_x, x
  compile_opt idl2, hidden
  common limitingSquaresBlock, q, u, xcen
  return, (threePotential(q, x, 0, 0) -  u)^2
end

function threeP_y, y
  compile_opt idl2, hidden
  common limitingSquaresBlock, q, u, xcen
  return, (threePotential(q, xcen, y, 0) - u)^2
end

pro debugTest
  x = findgen(200) / 40. - 2.5
  y = x
  z = x * 0
  xs = rebin(x, 200, 200)
  ys = rebin(1#y, 200, 200) 
  zs = rebin(z, 200, 200)
  q = .357
  ubase = threePotential(q, l1(q), 0, 0)
  for u = ubase * 1.30,  ubase * .85, -ubase * .1 do begin
     pot = threePotential(q, xs, ys, zs)
     
     limitingSpheres, q, u, xcen, r1, r2, /primary
     loadct, 0, /silent
     contour, pot, x, y, lev = u
     theta = findgen(100) / 99 * 2 * !pi
     oplot, xcen + r1 * cos(theta), r1 * sin(theta), color = fsc_color('crimson')
     oplot, xcen + r2 * cos(theta), r2 * sin(theta), color = fsc_color('plum')
     wait, .5
  endfor
end
  
;+
; PURPOSE: 
;  This procedure characterizes the shapes of tidally
;  distorted binary stars. For a given binary component (primary /
;  secondary) It determines the radii of the smallest sphere
;  completely outside the star, and the biggest sphere completely
;  inside the star. Both spheres are centered on the star. This is
;  useful for eclipse testing, since any line of sight which falls
;  within the small sphere is certainly eclipsed, while any LOS which
;  falls outside the big sphere certainly isn't.
;
;  This seems to work rather robustly for detached, semi-detached, and
;  contact binaries. It does not seem to work with overcontact
;  binaries.
;
; CATEGORY:
;  Three body problem
;
; CALLING SEQUENCE:
;  limitingSpheres, q, u, x, r1, r2, [/PRIMARY]
;
; INPUTS:
;  q: The mass ratio of the system (secondary / primary)
;  u: The 3 body pseudo-potential which characterizes the stellar
;     surface (as returned by, for example, threePotential)
;
; KEYWORD PARAMETERS:
;  PRIMARY: By default, this procedure calculates limiting spheres for
;  the secondary component. Set this keyword to use the primary
;  instead.
;  tol: The fractional tolerance to which the boundaries are
;  calculated. Defaults to 10^-5.
;
; OUTPUTS:
;   x: The center of the spheres (the center of the star)
;  r1: The radius of the smaller limiting sphere
;  r2: The radius of the larger limiting sphere
;
; COMMON BLOCKS:
;  limitingSquaresBlock is created, which holds q and u
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, Feb 2009
;-  
PRO limitingSpheres, q, u, x, r1, r2, PRIMARY = primary, tol = tol
compile_opt idl2
on_error, 2

;- check inputs
if n_params() ne 5 then begin
   print, 'calling sequence:'
   print, 'limitingSpheres, q, u, r1, r2, [/primary]'
   return
endif

if q lt 0 || q gt 1 then $
   message, 'q must be [0,1]'

if u le 0 then $
   message, 'u must be > 0'

if n_elements(tol) eq 0 then tol = 1d-5

xcen = keyword_set(primary) ? - q / (1 + q) : 1 / (1 + q)

;-set up common block
common limitingSquaresBlock, massRatio, potential, center
massRatio = q
potential = u
center = xcen

;-find the boundary points
lox = newton1D('threeP_x', xcen + 1d-1, tol)
hix = newton1D('threeP_x', xcen - 1d-1, tol)
hiy = newton1D('threeP_y', -1d-3, tol)
hiz = newton1D('threeP_z', -1d-3, tol)

radii = [abs(lox - xcen), abs(hix - xcen), hiy, hiz]
sorted = sort(radii)

;-results
x = xcen
r1 = radii[sorted[0]]
r2 = radii[sorted[3]]
return

end
