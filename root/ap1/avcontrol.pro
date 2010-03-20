;+
; NAME:
;  AVCONTROL
;
; DESCRIPTION:
;  This procedure takes as input a set of multi-band magnitudes for a
;  collection of stars. It calculates and returns the average colors
;  and color-covariance matrix for these measurements. This
;  information is used in the NICER algorithm described in Lombardi
;  and Alves 2001, and implemented in the procedure NICER.pro
;
; CALLING SEQUENCE:
;  AVCONTROL, mags, color, covar
;
; INPUT PARAMETERS:
;  mags: An m by n array of magnitudes in m different bands for n
;        stars.
;
; OUTPUT PARAMETERS:
;  color: An m-1 element vector giving the average colors. color[i]
;         gives <mags[i] - mags[i+1]>
;  covar: The covariance matrix for each of the m-1 colors.
;
; MODIFICATION HISTORY:
;  December 2008: Written by cnb
;-
PRO AVCONTROL, mags, color, covar

compile_opt idl2

;-check for input
if n_params() ne 3 then begin
    print, 'AVCONTROL calling sequence: '
    print, 'AVCONTROL, mags, color, covar'
    print, '  mags: m by n element array of m-band photometry for n sources'
    print, ' color: A named variable to hold the output average colors'
    print, ' covar: A named variable to hold the output covariance matrix'
    return
endif

sz = size(mags)
if sz[0] ne 2 then message, 'mag vector must be a 2D array'

nband = sz[1]
nstar = sz[2]

color = fltarr(nband - 1)
covar = fltarr(nband - 1, nband - 1)

for i = 0, nband-2, 1 do $
    color[i] = mean(mags[i,*] - mags[i+1,*], /nan)
    
for i = 0, nband - 2, 1 do begin
    for j = 0, nband - 2, 1 do begin
        covar[i,j] = mean( (mags[i,*] - mags[i+1,*] - color[i]) * $
                           (mags[j,*] - mags[j+1,*] - color[j]), /nan)
    endfor
endfor

return
end
