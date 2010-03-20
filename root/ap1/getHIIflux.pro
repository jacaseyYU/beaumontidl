;+
; NAME:
;  getHIIflux.pro
;
; DESCRIPTION:
;  Use hIIfluxes.dat to return the HII flux of a bubble
;-

function getHIIflux, bubble
on_error, 2

readcol, '~/glimpse/pro/hIIfluxes.dat', num, sz, flux, /silent, comment='#'

hit = where(bubble eq num, ct)

if ct eq 0 then message, 'Bubble not found in hIIfluxes.dat'

;-check for no emission
if sz[hit[0]] eq 0 then return, 0 

;-check for no data
if sz[hit[0]] lt 0 or ~finite(flux[hit[0]]) then return, !values.f_nan

return, flux[hit[0]]

end
