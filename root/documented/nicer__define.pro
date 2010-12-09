function nicer::weight, id, x, y
  ;- gaussian filter
  super = self->skymap::weight(id, x, y)
  ;- av correction factor
  super *= 10^(self.alpha * self.k * *self.val)
  return, super
end

;+
; PURPOSE:
;  Set the value of alpha, the slope of the number counts
;
; INPUTS:
;  alpha: The new value
;-
pro nicer::setAlpha, alpha
  self.alpha = alpha
end

;+
; PURPOSE:
;  Return the value of alpha
;
; OUTPUTS:
;  alpha
;-
function nicer::getAlpha
  return, self.alpha
end

pro nicer::init, map, x, y, val, dval, $
                 fwhm = fwhm, truncate = truncate, $
                 verbose = verbose, alpha = alpha, k = k
                
  if n_params() eq 0 then begin
     print, 'calling sequence:'
     print, 'obj = obj_new("nicer", map, x, y, val, dval, '
     print, '               [fwhm = fwhm, truncate = truncate, '
     print, '                k = k, alpha = alpha, /verbose]'
     return, 0
  endif
            
  super = self->skymap::init(map, x, y, val, dval, $
                             fwhm = fwhm, truncate = truncate, $
                             verbose = verbose)
  if ~super return, 0

  if n_elements(alpha) ne 0 then self.alpha = alpha
  if n_elements(k) ne 0 then self.k = k else self.k = 1
end

pro nicer__define
  nicer = {nicer, inherits skymap, $
           beta:0., $
           alpha: 0., $
           k: 0.}
end
           
