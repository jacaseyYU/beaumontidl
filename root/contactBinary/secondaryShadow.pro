function parametricPotential, u
  common secondaryShadowBlock, q, x, y, z, i, dx, dy, dz
  return, (-100) > (-1 * threePotential(q, $
                          x[i] + u * dx, $
                          y[i] + u * dy, $
                          z[i] + u * dz))
end

pro debug
  x = findgen(200) / 40. - 2.5
  y = x
  z = x * 0
  xs = rebin(x, 200, 200)
  ys = rebin(1#y, 200, 200)
  zs = rebin(z, 200, 200)
  q = .357
  u = threePotential(q, L1(q), 0, 0)
  shadow = secondaryShadow(.357, u, reform(xs, 200 * 200L), $
                           reform(ys, 200 * 200L), reform(zs, 200 * 200L), 70, 0)
  pot = threePotential(q, xs, ys, zs)
  limitingSpheres, q, u, xcen, r1, r2

  contour, pot, x, y, lev = [u], xra = [-1, 1.5], yra=[-1, 1]
  oplot, xcen + r1 * sin(findgen(100) / 10), r1 * cos(findgen(100) / 10), color=fsc_color('crimson')
  oplot, xcen + r2 * sin(findgen(100) / 10), $
         r2 * cos(findgen(100) / 10), color = fsc_color('crimson')
  contour, reform(shadow, 200, 200), x, y, lev = [1], /overplot, color = fsc_color('blue')
end


;+
; PURPOSE:
;  This function determines whether a given set of coordinates in the
;  three-body reference frame are eclipsed by the system's
;  secondary star.
;
; CATEGORY:
;  Three body problem, Light curve analysis
;
; CALLING SEQUENCE:
;  result = secondaryShadow( q, u, x, y, z, inc, phi, RES = res)
;
; INPUTS:
;  q: The mass ratio (secondary / primary) of the system
;  u: The 3body pseudo potential (as determined by, say,
;  threePotential) which describes the secondary star's surface.
;  x: The X coordinate(s) to test. The X axis points joins the primary
;  and secondary
;  y: The Y coordiante(s) to test. The y axis lies in the orbital plane 
;  z: The Z coordinate(s) to test. The z axis lies perpendicular to
;  the orbital plane
;  inc: The inclination of the system, in degrees (90 = edge on)
;  phi: The orbital phase of the system (0 = secondary in front of
;  primary). Measured in degrees.
;
; KEYWORD PARAMETERS:
;  RES: A factor to adjust the resolution at which the
;  secondary star's surface is calculated. Higher values result
;  in a slower algorithm, but a more accurate definition of the
;  secondary star surface. Default value is 1.
;
; OUTPUTS:
;  A scalar or array, equal in length to the x/y/z data. The output is
;  set to one if the corresponidng (x,y,z) point is visible, and 0 if
;  it is eclipsed by the secondary
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, Feb 2009
;-
function secondaryShadow, q, u, x, y, z, inc, phi, RES = res
testing = 0

sz = n_elements(x)

;- set up the common block
common secondaryShadowBlock, massRatio, xpts, ypts, zpts, i, dx, dy, dz
massRatio = q
xpts = x
ypts = y
zpts = z
pot = u
  
;-the unit vector pointing away from the point in question towards the
;-observer
dx = sin(inc * !dtor) * cos(phi * !dtor)
dy = sin(inc * !dtor) * (-1) * sin(phi * !dtor)
dz = cos(inc * !dtor)

;-get limiting spheres
limitingSpheres, q, u, xcen, r1, r2

;-find the point of closest approach for each (x,y,z)
closest = closestApproach(xcen, 0, 0, x, y, z, $
                          x + dx, y + dy, z + dz,$
                          dist = dist)
len = closest[*,0] - x

result = bytarr(sz)
for i = 0L, sz - 1, 1 do begin
   
;-easy cases determined by the limiting spheres  
   m_mid = (closest[i, 0] - x[i]) / dx
   closestM = (m_mid lt 0) ? 0 : m_mid
   closestX = x[i] + closestM * dx
   closestY = y[i] + closestM * dy
   closestZ = z[i] + closestM * dz
   closestDist = sqrt((closestX - xcen)^2 + closestY^2 + closestZ^2)

   if closestDist gt r2 then begin
      result[i] = 1
      continue
   endif else if closestDist lt r1 then begin
      result[i] = 0
      continue
   endif

;-parameterize the line of sight by the scalar m
;- p = p0 + m * dP
;- the los passes through the r2 sphere at two points. Find the m
;  values for these two points, and sample the potential along this
;  line segment
   
   m_mid = (closest[i, 0] - x[i]) / dx
   delta_m = (sqrt(r2^2 - dist[i]^2))
 
;- think that this is taken care of above  
;   if (m_mid le delta_m) then begin
;      result[i] = 2 ;- point lies in front of the limiting spheres
;      continue
;   endif

   m_low = (m_mid - delta_m) > 0
   m_hi = m_mid + delta_m
   
   if (testing) then begin
      plot, xcen + r2 * cos(findgen(200)/ 20), r2 * sin(findgen(200) / 20)
      oplot, xcen + r1 * cos(findgen(200)/ 20), r1 * sin(findgen(200) / 20)
      
      oplot, [x[i] + m_mid * dx], [y[i] + m_mid * dy], psym = 4, color = fsc_color('crimson')
      oplot, x[i] + dx * [m_low, m_hi],  y[i] + dy * [m_low, m_hi]
      oplot, [x[i]], [y[i]], psym = 6, symsize = 2, color=fsc_color('blue')
      wait, .2
   endif

   m_sample = findgen(50) / 49. * (m_hi - m_low) + m_low
   u_sample = fltarr(50)
   for j = 0, 49, 1 do u_sample[j] = parametricPotential(m_sample[j])
   lo_u = min(u_sample, loc)
   
   umin = newton1d('parametricPotential', m_sample[loc], 1d-4, $
                   minvalue = minvalue, $
                  range = m_low > $
                   m_sample[loc] + (m_hi - m_low) / 50. * [-1,1] $
                   < m_hi)

   ;conditions for non-eclipse
   if (-minvalue lt u) || (umin * dx) lt 0 then $
      result[i] = 1
endfor

;- flag out points inside secondary
bad = where(threePotential(q, x, y, z) gt u and $
            (x - xcen)^2 + y^2 + z^2 lt r2^2, badct)
if badct ne 0 then result[bad] = 0

return, result
end

;- coord system
;- Binary frame:
;  x- Towards secondary
;  y- Orbital plane
;  z- Spin axis
;  Observer Frame
;  u- Towards observer 
;  v- Towards the west(right), in the sky plane
;  w- North, in the sky plane
