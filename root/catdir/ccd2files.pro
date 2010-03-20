;+
; PURPOSE:
;  This function finds which files in an
;  images.dat structure correspond to a given
;  megacam ccd ID number.
;
; INPUTS:
;  ccd: The ccd number to search for
;  images: The images.dat structure
;
; KEYWORD PARAMETERS:
;  names: Set to a variable to hold the names of the matched images.
;
; OUTPUTS:
;  The zero-based index of the matching images.
;
; MODIFICATION HISTORY:
;  October 2009: Written by Chris Beaumont
;-
function ccd2files, ccd, images, names = names

  ;- check inputs
  if n_params() ne 2 then begin
     print, 'ccd2files calling sequence:'
     print, 'result = ccd2files(ccd, images, [names = names])'
     return, -1
  endif

  hit = where(strmatch(images.name, '*ccd'+string(ccd, format='(i2.2)')+'*'),ct)
  if ct eq 0 then $
     message, ' Did not find any matches to '+string(ccd)

  names = images[hit].name
  return, hit

end
