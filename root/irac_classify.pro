;+
; PURPOSE:
;  This function applies the series of color cuts described in
;  Gutermuth et al. 2008 (ApJ 674, 336) in an attempt to classify
;  IRAC sources towards embedded clusters. Possible classifications
;  include PAH galaxies, strong PAH emitters, AGN, protostars, and
;  class II sources.
;
; CATEGORY:
;  astrophysics
;
; INPUTS:
;  i36: A vector of IRAC band 1 magnitudes. Should be de-reddened.
;  i45: A vector of IRAC band 2 magnitudes. Should be de-reddened.
;  i58: A vector of IRAC band 3 magnitudes. Should be de-reddened.
;  i8 : A vector of IRAC band 4 magnitudes. Should be de-reddened.
;
; KEYWORD PARAMETERS:
;  GET: If present, the function will instead returned a
;  structure. The field names of this structure correspond to the
;  possible classificaion id names, and the values of each field
;  correspond to the value assigned to each classification id. 
;
; OUTPUTS:
;  A vector of classification numbers. The names associated with each
;  classification number are stored in the structure returned by
;  setting \GET. 
;
; MODIFICATION HISTORY:
;  November 2009: Written by Chris Beaumont
;-
function irac_classify, i36, i45, i58, i8, get = get

  id = {PAH_GALAXY : 1B, $  
        STRONG_PAH : 2B, $
        AGN : 3B, $
        SHOCKED : 4B, $
        PROTOSTAR : 5B, $
        CLASS2 : 6B}
 
  if keyword_set(get) then return, id
             
  ;- check inputs
  if n_params() ne 4 then begin
     print, 'irac_classify calling sequence: '
     print, 'result = irac_classify(i36, i45, i58, i8, [/get])'
  endif

  sz = n_elements(i36)
  if n_elements(i45) ne sz || $
     n_elements(i58) ne sz || $
     n_elements(i8) ne sz then $
        message, 'i36, i45, i58, i8 do not have the same number of elements'

  result = bytarr(sz)

  ;- pah galaxies
  cut1 = (i45 - i58) lt (1.05 / 1.2) * (i58 - i8 - 1) and $
           (i45 - i58) lt 1.05 and $
           (i58 - i8) gt 1
  cut2 = (i36 - i58) lt (1.5 / 2) * (i45 - i8 - 1) and  $
           (i36 - i58) lt 1.5 and $
           (i45 - i8) gt 1
  hit = where(cut1 or cut2, ct)
  if ct ne 0 then result[hit] = id.PAH_GALAXY

  ;- source is too strong of a pah emitter
  cut1 = i45 lt 11.5
  hit = where(cut1, ct)
  if ct ne 0 then result[hit] = id.STRONG_PAH

  ;- agn flagging
  cut1 = (i45 - i8) gt 0.5 and $
         i45 gt 13.5 + (i45 - i8 - 2.3) / 0.4 and $
         i45 gt 13.5
  cut2 = i45 gt 14 + (i45 - i8 - 0.5) or $
         i45 gt 14.5 - (i45 - i8 - 1.2) / 0.3 or $
         i45 gt 14.5
  hit = where(cut1 and cut2, ct)
  if ct ne 0 then result[hit] = id.AGN

  ;- shocked emission
  cut1 = i36 - i45 gt (1.2 / 0.55) * (i45 - i58 - 0.3) + 0.8 and $
         i45 - i58 le 0.85 and $
         i36 - i45 gt 1.05
  hit = where(cut1, ct)
  if ct ne 0 then result[hit] = id.SHOCKED

  ;-protostar
  cut1 = i45 - i58 gt 1
  cut2 = i45 - i58 gt 0.7 and $
         i45 - i58 le 1.0 and $
         i36 - i45 gt 0.7
  hit = where((cut1 or cut2) and (result eq 0), ct)
  if ct ne 0 then result[hit] = id.PROTOSTAR

  ;-class II source
  cut1 = i45 - i8 gt 0.5 and $
         i36 - i58 gt 0.35 and $
         i36 - i58 le (0.14 / 0.04) * (i45 - i8 - 0.5) + 0.5
  hit = where(cut1 and (result eq 0), ct)
  if ct ne 0 then result[hit] = id.CLASS2

  return, result
end
