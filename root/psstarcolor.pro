;+
; PURPOSE:
;  This function returns colors of stars, in the Pan-STARRS filter set,
;  in the AB magnitude system. The values are read in from tables
;  generated by pickles2pscolors, which in turn use data from the
;  Pickles Spectral library and Trent Dupuy's calculation of PS
;  colors for low mass stars. 
;
; INPUTS:
;  type: The spectral type of interest. 0-8, indicating
;        0,B,...,M,L,T. Scalar or vector.
;  subtype: The subtype. Eg (type, subtype) = (0,7) corresponds to an
;           07 star
;  class: The luminosity class to consider. 1-5 (5 is main sequence)
;
; OUTPUTS:
;  The 4 pan-starrs colors (g-r, r-i, i-z, z-y) for each star.
;
; PROCEDURE:
;  This function reads in tables generated by
;  pickles2pscolors. Missing data is returned as NAN. Magnitudes are
;  in the AB system.
;
; Example:
;  Find the colors of a K3 supergiant
;  colors = psstarcolor(5, 3, 1)
;
; MODIFICATION HISTORY:
;  Dec 2009: Written by Chris Beaumont
;  Feb 2010: Fixed a problem that arose when only one star is
;            requested
;  Mar 2010: Added parameter checking
;
;-
function psstarcolor, type, subtype, class
  compile_opt idl2
  on_error, 2

  ;- check input
  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, 'result = psstarcolor(type, subtype, class)'
     print, 'type = 0-8 = O-T spectral type'
     print, 'result = [g-r, r-i, i-z, z-y]'
     return, !values.f_nan
  endif
  sz =n_elements(type)
  if n_elements(subtype) ne sz || n_elements(class) ne sz then $
     message, 'type, subtype, and class must be the same size'


  ;- read in data tables
  common psstarcolor_common, colors
  if n_elements(colors) eq 0 then begin
     dir = '/home/beaumont/idl/data/pickles_speclib/pscolors_'
     files = ['i','ii','iii','iv','v']
     colors = fltarr(4, 90, 5)
     table = fltarr(5, 90)
     for i = 0, 4, 1 do begin
        openr, lun, dir+files[i]+'.dat', /get
        readf, lun, table, format='((i3, 3x, 4(f6.2, 2x)))'
        close, lun
        free_lun, lun
        colors[*,*,i] = table[1:4, *]
     endfor
  endif

  num = n_elements(type)
  y = rebin([type * 10 + subtype], num, 4)
  z = rebin([class - 1], num, 4)
  x = rebin(1#[0,1,2,3], num, 4)
  result = transpose(colors[x,y,z])
  
  return, result
end
  
pro test
  type = [4, 5, 6, 7, 8]
  subtype = [0, 5, 7, 5, 3]
  class = [5, 4, 3, 5, 5]
  color = psstarcolor(type, subtype, class)
  name = ['o', 'b', 'a', 'f', 'g', 'k', 'm', 'l', 't']
  for i = 0, n_elements(color[0,*]) - 1, 1 do begin
     print, name[type[i]]+strtrim(subtype[i],2)+': '+strtrim(class[i],2), color[*,i]
  endfor
end

