;+
; PURPOSE:
;  This function calculates model absolute V magnitudes for low mass
;  objects as a function of mass and age. It interpolates the DUSTY model grid
;  given in Chabrier et al 2000ApJ...542..464C. Data requested outside
;  the range of model parameters are snapped to the edge of the model
;  grid.
;
; CATEGORY:
;  Stellar evolution
;
; CALLING SEQUENCE:
;  result = dustymag(masses, ages, filter = filter)
;
; INPUTS:
;  masses: The requested mass(es), in solar masses. Scalar or vector
;  
;  ages: The requested age(s), in Gyr. Scalar or vector. agees and masses must
;  have the same number of elements
;
; KEYWORD PARAMETERS:
;  filter: A single character requesting which band magnitudes should
;  be reported in. Choices are 'v, r, i, z, y, j, k, l, m'. The z and
;  y filters are not in the dusty model, but are interpolated from the
;  i and j models.
;
; OUTPUTS:
;  The interpolated absolute magnitudes for the requested objects.
;
; NOTE:
;  This procedure restores the file '~/idl/data/dustygrid.sav', created by the
;  program dustygrid.pro
;
; SEE ALSO:
;  dustygrid, baraffemag, bastimag, mass2mag
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;-
function dustymag, masses, ages, verbose = verbose, filter = filter
  compile_opt idl2
  ;- check inputs
  if n_params() ne 2 then begin
     print, 'dustymag calling sequence:'
     print, 'result = dustymag(masses, ages)'
  endif
  
  sz = n_elements(masses)
  if sz eq 0 then $
     message, 'input has no elements'
  if n_elements(ages) ne sz then $
     message, 'masses and ages do not have the same number of elements'
  
  if ~keyword_set(filter) then filter='v'
  
  restore, '~/idl/data/dustygrid.sav'
  
  i_lamb = 750D
  z_lamb = 870D
  y_lamb = 990D
  j_lamb = 1260D
  wz = (z_lamb - i_lamb) / (j_lamb - i_lamb)
  wy = (y_lamb - i_lamb) / (j_lamb - i_lamb)
  
;- select which filter to use
  case filter of
     'v': mag = vgrid
     'r': mag = rgrid
     'i': mag = igrid
     'z': mag = (1 - wz) * igrid + wz * jgrid
     'y': mag = (1 - wy) * igrid + wy * jgrid
     'j': mag = jgrid
     'k': mag = kgrid
     'l': mag = lgrid
     'm': mag = mgrid
     else: message, 'filter must be one of v,r,i,z,y,j,k,l,m'
  endcase
  
;- prevent extrapolation
  mlo = .01
  mhi = .1
  agelo = .1
  agehi = 10
  mass = mlo > masses < mhi
  age = agelo > ages < agehi
  
;- step 1- interpolate requested masses and ages into 'grid
;  coordinates'
  nmass = n_elements(gridmass)
  nage = n_elements(gridage)
  mass_ind = interpol(findgen(nmass), gridmass, mass)
  age_ind = interpol(findgen(nage), gridage, age)
  
;- step 2 - interpolate model gred onto these grid coordinates
  result = interpolate(mag, mass_ind, age_ind, cubic = -0.5)
  return, result
end
