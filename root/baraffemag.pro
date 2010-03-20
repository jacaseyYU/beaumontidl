;+
; PURPOSE:
;  This function interpolates the baraffe stellar evolution grids onto
;  a set of specified masses and ages. The Baraffe models are taken
;  from Baraffe et al 1998A&A...337..403B.
;
; CATEGORY:
;  stellar evolution
;
; CALLING SEQUENCE:
;  result = baraffemag(inMass, inAge, filter = filter)
;
; INPUTS:
;  inMass: A scalar or vector of masses (in solar masses). The Baraffe
;  grid is calculated for .075 < M / M_solar < 1.
;
;  inAge:  A scalar or vector of ages (in Gyr). The Baraffe grid is
;  calculated for age < 12.6 Gyr.
;
; KEYWORD PARAMETERS:
;  filter: A single character specifying which filter to calculate
;  magnitudes for. Options are 'v,r,i,z,y,j,h,k'. However, z and y are
;  not in the actual model grids; they are interpolated from the
;  values for i and j.
;
; OUTPUT:
;  The absolute magnitudes of the objects given by inMass and
;  inAge. Objects which fall outside of the mass/age grid are returned
;  as nans.
;
; NOTE:
;  This function restores the file created from baraffegrid.pro, and
;  assumed to be located at '~/idl/data/baraffe.sav'. 
;
; SEE ALSO:
;  baraffegrid, dustymag, bastimag, mass2mag
;-
function baraffemag, inMass, inAge, filter = filter

restore, '~/idl/data/baraffe.sav'

i_lamb = 750D
z_lamb = 870D
y_lamb = 990D
j_lamb = 1260D
wz = (z_lamb - i_lamb) / (j_lamb - i_lamb)
wy = (y_lamb - i_lamb) / (j_lamb - i_lamb)

if ~keyword_set(filter) then filter='v'
case filter of 
   'v': mag = v
   'r': mag = r
   'i': mag = i
   ;- interpolate z and y
   'z': mag = (1 - wz) * i + wz * j
   'y': mag = (1 - wy) * i + wy * j
   'j': mag = j
   'h': mag = h
   'k': mag = k
   else: message, 'filter must be one of v,r,i, z, y, j, h, k'
endcase

extrapolate = where(inMass gt 1 or $
                    inMass lt .075 or $
                    inAge gt 12.6, exct)

result = griddata(mass, age, mag, xout = inMass, yout = (inAge > .002), $
                   /linear, triangles = triangles)

if exct ne 0 then result[extrapolate] = !values.f_nan

return, result

end
