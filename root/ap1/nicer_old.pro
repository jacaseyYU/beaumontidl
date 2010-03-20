;+
; NAME:
;  NICER
; 
; DESCRIPTION:
;  This function estimates the reddening to a star based on its JHK
;  colors. Based on the NICER algorithm (Lombardi and Alves, 2001).
;
; CALLING SEQUENCE:
;  result=NICER(j,dj,h,dh,k,dk)
; 
; INPUTS:
;  J,H,K: scalar or n-element vectors of a set of J,H,K magnitudes of a
;         star. If any data are missing, insert fake data and see next
;         sentnce.
;  dH,dJ,dK: scalar or n-element vectors of the errors in the JHK
;            colors. If any JHK data are unknown, insert fake data for
;            those entries, and make the corresponding error entry
;            extremely large. This will cause the algorithm to ignore
;            the fake data point during fitting.
;
; OUTPUT:
;  A 2 x n element array giving nth row gives the magnitudes of
;  visual extinction, with associated error, estimated for star n.
;
; CATEGORIES:
;  Photometry, Interstellar extinction
;
; MODIFICATION HISTORY:
;  July 2008: Written by Chris Beaumont
;- 
function nicer, j, dj, h, dh, k, dk, color = color, covar = covar

;quick reformat
j=reform(j)
dj=reform(dj)
h=reform(h)
dh=reform(dh)
k=reform(k)
dk=reform(dk)

;- k=E/Av

k1=1/9.35
k2=1/15.87

;- assemble the covariance matrix in eq 10. Additive constants are
;  output from av_control procedure with js's control field
if ~keyword_set(covar) then begin
    cov11 = dj^2 + dh^2 + .0280821 
    cov12 = -dh^2 + .00293       
    cov21 = -dh^2 + .00293       
    cov22 = dh^2 + dk^2 + .02765 
endif else begin
    cov11 = covar[0,0] + dj^2 + dh^2
    cov12 = covar[0,1] - dh^2
    cov21 = covar[1,0] - dh^2
    cov22 = covar[1,1] + dh^2 + dk^2
endelse

;- invert the covariance matrix
cdet = (cov22*cov11)-(cov12*cov21)
ci11 = 1/cdet*cov22
ci12 = -1/cdet * cov12
ci21 = -1/cdet * cov21
ci22 = 1/cdet * cov11

;- solve equation 12
numer1 = ci11 * k1 + ci12 * k2
numer2 = ci21 * k1 + ci22 * k2
denom = k1 * numer1 + k2 * numer2

b1 = numer1 / denom
b2 = numer2 / denom

;- calculate Av from eq 13, and sigma from eq 9
if ~keyword_set(color) then color = [.487419, .134643]
av = b1 * ((j-h) - color[0]) + b2 * ((h-k) - color[1])
sv = sqrt(b1 * b1 * cov11 + b1 * b2 * cov12 + b2 * b1 * cov21 + b2 * b2 * cov22)

;- check against equation 7
if max(abs(b1*k1+b2*k2-1)) ge 3*(machar()).eps then message,'Error- Eq 7 not satisfied'

;-visually inspect
;plot,(h-k)-k2*av, (j-h)-k1*av,psym=3, xra=[-1.,2.5], yra=[-.5,3.],/xsty,/ysty
;oplot, [.188919], [.5007], psym=4, color='ff0000'xl
;oplot, (h-k), (j-h), color='00ff00'xl,psym=4

return,transpose([[av],[sv]])

end
