;+
; PURPOSE:
;  This function is used in conjunction with powerlaw_xmin_golden to
;  find the best fit xmin for a powerlaw. It uses a common block to
;  store the data, and returns the ks statistic from powerlaw_fitexp
;
; CATEGORY:
;  power law, statistics
;
; CALLING SEQUENCE:
;  result = powerlaw_ks(x)
;
; INPUT:
;  x: A guess for the value of xmin in a powerlaw fit.
;
; OUTPUT:
;  The KS statistic of the best fit powerlaw distribution to the data,
;  assuming the value of xmin = x.
;
; COMMON BLOCKS:
;  This function uses the data variable from the powerlaw_data common block
;
; MODIFICATION HISTORY:
;  May 2009: Written by Chris Beaumont
;-
function powerlaw_ks, x, _extra = extra
compile_opt idl2
on_error, 2

common powerlaw_data, data

if n_elements(data) eq 0 then $
   message, 'you must create the powerlaw_data common block first!'

alpha = powerlaw_fitexp(data, x, ksd = k)

return, k

end
