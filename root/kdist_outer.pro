function kdist_outer, long, vel, radians = radians

  if keyword_set(radians) then $
     l = long $
  else $
     l = long * !dtor

  if l le !pi/2 or l ge 3 * !pi / 2 then $
     message, 'Longitude must be between pi/2 and 3pi/2'

  if l gt !pi then $
     l = 2 * !pi - l

;- notation:
; v : rotation velocity
; vo: Solar rotation velocity
; vr: Radial velocity wrt LSR
; r : Galactocentric radius
; ro: Solar galactocentric radius

;rotation curve parameters from Brand and Blitz 1993
; v/vo = a1 * (R/Ro)^a2 + a3
; vr = sin(l) * vo * [ a1 * (r/ro)^(a2-1) + a3*(r/ro)^-1 - 1]

  a1=1.0077D
  a2=.0394D
  a3=.0077D


;- the following are from arxiv 0902.3913 (VLBI parallax)
;  - value taken from section 4, the best fit to this particular roation curve
  ro = 8.8
  vo = 275.

  d = arrgen(0., 5 * ro, nstep = 5000)
  r = sqrt(ro^2 + d^2 - 2 * ro * d * cos(l))
  theta = acos((r^2 + d^2 - ro^2) / (2 * r * d))
  root = vo * (a1 + (r/ro)^a2 + a3) * sin(theta) - vo * sin(l) - vel
  backup = root

;- find the root
  root *= shift(root, 1)
  root[0] = 1
  root[n_elements(root)-1] = 1
  hit = where(root lt 0, ct)

  if ct eq 0 then begin
     print, 'Could not find outer galactic distance'
     return, [!values.f_nan, !values.f_nan]
  endif

  return, [d[hit[0]], d[hit[0]]]
end
