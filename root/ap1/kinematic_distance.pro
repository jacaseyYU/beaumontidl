;+
; NAME:
;  KINEMATIC_DISTANCE
;
; PURPOSE:
;  This function calculates the near and far kinematic distances for a
;  given galactic longitude and radial velocity. The calculation uses
;  the Galactic rotaion model of Brand and Blitz 1993, A&A, 275 : 67.
;
; CALLING SEQUENCE:
;  result=KINEMATIC_DISTANCE( Latitude, Velocity, [/DEGREE])
;
; INPUTS:
;  Latitude: Galactic Latitude. Currently must be in the range [-180,
;  180] in degrees.
;
;  Velocity: Radial velocity in km/s
;
; KEYWORD PARAMETERS:
;  /DEGREE: If set, input Latitude is in degrees
;
; OUTPUT:
;  The two element vector [near_distance, far_distance] in kpc.
;
; RESTRICTIONS:
;  Currently only computes distances for objects in the inner galaxy.  
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont, June 2008.
;-

FUNCTION kinematic_distance, l, v, degrees=degrees

on_error, 2

if n_params() ne 2 then begin
    message,'Calling Sequence: dist=kinematic_distance(l,v,[/degrees])'
endif

if n_elements(l) ne n_elements(v) then message,'Error -- l and v must be the same size'

if keyword_set(degrees) then l/=!radeg
l=(l mod (2*!dpi))

if (l ge !pi/2) && (l lt 3*!pi/2) then message, 'Error -- Latitude must be acute'

;rotation curve parameters from Brand and Blitz 1993
; v/vo = a1 * (R/Ro)^a2 + a3
; vr = sin(l) * vo * [ a1 * (r/ro)^(a2-1) + a3*(r/ro)^-1 - 1]

a1=1.00767
a2=.0394
a3=.00712
ro=8.5
vo=220

;determine r to the nearest .01 kpc
r=(findgen(850)+1)/850.*8.5
root=sin(l) * vo * (a1 * (r/ro)^(a2-1) + a3 * (r/ro)^(-1) - 1) - v


;find the zero crossing
root*=shift(root,1)
root[0]=1

root[n_elements(root)-1]=1

hit=where(root lt 0, ct)

r=r[hit[0]]


rmin=ro*cos(l)
dr=sqrt(r^2-(ro*sin(l))^2)

return,[rmin-dr,rmin+dr]

end
