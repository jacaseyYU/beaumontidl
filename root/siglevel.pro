;+
; PURPOSE:
;  This function finds the contour level of a pdf which surrounds a
;  given fraction of the total probability. That is, given a
;  probability density function P(x1, ..., xn), calculate the level f
;  for which 
;        Sum(P > f) / Sum(P) = significance  (1)
;
; CATEGORY:
;  Probability
;
; CALLING SEQUENCE:
;  result = SIGLEVEL(data, significance, [acc = acc, /verbose]
;
; INPUT:
;  data: A non-negative array, representing the probability density
;  function sampled across some parameter space. This need not be 2D,
;  nor need it be normalized.
;  significance: The desired fraction of total probability to encircle
;
; KEYWROD PARAMETERS:
;  acc: The fractional accuracy of the desired significance
;  level. That is, the return value f will be such that 
;       abs(Sum(P > f) / Sum(P) - significance) < acc
;  the default value is .01
;  verbose: Display extra output.
;
; OUTPUT:
;  The value of f which satisfies equation (1).
;
; MODIFICATION HISTORY:
;  April 25 2009: Written by Chris Beaumont
;-
function siglevel, data, significance, acc = acc, verbose = verbose
compile_opt idl2
;on_error, 2

;- check inputs
if n_params() ne 2 then begin
   print, 'siglevel calling sequence:'
   print, ' result = siglevel(data, significance, [acc = acc, /verbose])'
   return, !values.d_nan
endif

if n_elements(data) lt 10 then message, 'data must have at least 10 elements'
if min(data,/nan) lt 0 then message, 'data must be non-negative'
if min(significance) le 0 || max(significance) ge 1 then $
   message, 'significance must be between 0 and 1'
if ~keyword_set(acc) then acc = 1d-2 > (1D / n_elements(data))

if 1D / n_elements(data) ge acc then $
   verbiage, 'Data does not contain enough elements to meet accuracy goals', $
             1, verbose

sort = sort(data)
n = n_elements(data)

ind = n * (1 - significance)
return, data[sort[ind]]

end
