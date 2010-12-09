;+
; PURPOSE:
;  Computes whether a variable is a scalar (i.e. has one element)
;
; MODIFICATION HISTORY:
;  December 2010: Written by Chris Beaumont
;-
function is_scalar, x
  return, n_elements(x) eq 1
end
