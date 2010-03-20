;+
; PURPOSE:
;  This function calculates a magnitude for a set of stellar masses and
;  ages based on the BaSTI model grid for solar-metallicity stars. The 
;  BaSTI database is located at http://albione.oa-teramo.inaf.it/
;
; CATEGORY:
;  Stellar Evolution
;
; CALLING SEQUENCE:
;  result = bastimag(inMass, inAge, filter = filter, /verbose)
;
; INPUTS:
;  inMass: a set of masses (in solar masses). Scalar or
;  vector. Masses less than .5 or greater than 10 are snapped to 5 and
;  10 solar masses.
;
;  inAge: a set of ages (in log(age/yr)). Scalar or vector.
;
; KEYWORD PARAMETERS:
;  FILTER: A single character requesting that the magnitude be
;  reported in a specific filter. Options are u, b, v, r, i, z, y, j, h, k,
;  and l. Z and Y are not included in the model grids, but are
;  interpolated from i and j. Default is v
;
;  VERBOSE: Print extra information
;
; OUTPUTS:
;   The nearest neighbor interpolation of the BaSTI grid onto the
;   requested masses/ages. If an age is requested outside of the model
;   grid, the star is assumed to have died and NAN is
;   reported. Likewise, stars above 10 solar masses are beyond the
;   grid and are reported as NAN. Stars below 0.5 solar are also
;   beyond the grid bounds, but are treated as .5 solar mass
;   objects. This helps bastimag interface with mass2mag
;
; NOTE:
;  The procedure restores a .sav file created from bastigrid, and
;  assumed to be located at '~/idl/data/basti.sav'
;
; SEE ALSO:
;  baraffemag, mass2mag, dustymag, bastigrid
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont.
function bastimag, inMass, inAge, filter = filter, verbose = verbose
compile_opt idl2
;on_error, 2

;- check input
if n_params() ne 2 then begin
   print, 'bastimag calling sequence:'
   print, ' result = bastimag(inMass, inAge, [filter = filter, /verbose])'
   print, 'filters: u,b,v,r,i,z,y,j,h,k,l'
   return, !values.f_nan
endif

sz = n_elements(inMass)
if sz eq 1 then begin
   inMass = [inMass]
   inAge = [inAge]
endif

if n_elements(inAge) ne sz then $
   message, 'inAge and inMass have different numbers of elements'

;- restore us, bs, ... and masses, ages, triangles, cutoffage, and cutoffmass
restore, file='~/idl/data/basti.sav' 

i_lamb = 750D
z_lamb = 870D
y_lamb = 990D
j_lamb = 1260D
wz = (z_lamb - i_lamb) / (j_lamb - i_lamb)
wy = (y_lamb - i_lamb) / (j_lamb - i_lamb)

if ~keyword_set(filter) then filter = 'v'
case filter of 
   'u' : mag = us
   'b' : mag = bs
   'v' : mag = vs
   'r' : mag = rs
   'i' : mag = is
   'z' : mag = (1 - wz) * is + wz * js
   'y' : mag = (1 - wy) * is + wy * js
   'j' : mag = js
   'h' : mag = hs
   'k' : mag = ks
   'l' : mag = ls
   else : $
      message, 'filter keyword must be one of (u, b, v, r, i, j, h, k, l)'
endcase

;- determine if any of the requested stars have died
lifetimes = interpol(cutoffage, cutoffmass, inMass)
dead = where(lifetimes lt inAge, deadct)

;- the program is bad at extrapolating. Kill things that are too
;-  massive
toobig = where(inMass gt 10, bigct)

;- interpolate magnitudes onto a grid
result = griddata(masses, ages, mag, /linear, triangles = triangles, $
                xout = (.5 > inMass < 10), yout = (-9 > inAge < 12))

if deadct ne 0 then result[dead] = !values.f_nan 
if bigct ne 0 then result[toobig] = !values.f_nan
return, result
end
