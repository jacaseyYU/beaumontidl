function grot, l, d


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

  ro = 8.8
  vo = 275.

;- get galactocentric dist
  x = d * sin(l)
  y = -ro + d * cos(l)
  r = sqrt(x^2 + y^2)

;- total velocity
  v = vo * (a1 * (r/ro)^a2 + a3)

;- direction of vel vector
  vxhat = -y / sqrt(x^2 + y^2)
  vyhat = x / sqrt(x^2 + y^2)

;- dot with radial velocity distance
  rxhat = sin(l)
  ryhat = cos(l)
  vrad = v * (vxhat * rxhat + vyhat * ryhat)

;- radial velocity of solar motion
  voxhat = 1
  voyhat = 0
  vorad = vo *  (voxhat * rxhat + voyhat * ryhat)
  print, 'exiting'
  result = vrad - vorad
  return, result
end
