;+
; NAME:
;  NICER
; 
; DESCRIPTION:
;  This function estimates the reddening of a star based on its IR
;  colors. Implementation of the NICER algorithm, and generalized 
;  to use IRAC colors as well (Lombardi and Alves, 2001).
;
; CALLING SEQUENCE:
;  result= NICER(j, dj, h, dh, k, dk, i1, di1, i2, di2)
; 
; INPUTS:
;   j: J magnitudes. Scalar or vector
;   h: H magnitudes. Scalar or vector
;   k: K magnitudes. Scalar or vector
;  dj: J magnitude errors.
;  dh: H magnitude errors.
;  dK: K magnitude errors.
;  i1: IRAC band 1 magnitude
;  i2: IRAC band 2 magnitude
; di1: IRAC band 1 magnitude errors
; di2: IRAC band 2 magnitude erros
;
; KEYWORD PARAMETERS:
;  color: If supplied, the field [j-h, h-k, k-1, 1-2] mean
;         colors. Default values are used otherwise.
;  covar: If supplied, the covariance of the above colors. Default
;         values are used otherwise
;
;  status: Each object must undergo a matrix inversion during this
;          procedure. this variable holds the 'status' kewyord of the
;          IDL builtin INVERT function. Nonzero values indicate trouble.
;
; OUTPUTS:
;  A 2 x n element array giving nth row gives the magnitudes of
;  visual extinction, with associated error, estimated for star n.
;
; PROCEDURE:
;  Note that all magnitudes and errors must be populated. However, all
;  information need not be present for the algorithm to succeed. If
;  certain measurements are not known, fill in junk values for the
;  corresponding magnidues, and enter in very large values for the
;  magnitude error. These data will effectively be ignored.
; 
;  Algorithm taken from Lombardi and Alves 2001. Equation references
;  in code refer to that paper. 
;  JHK extinction law taken from Lebofsky 1985
;  IRAC extinction law taken from Indebetouw, Mathis et al. 2005
;
;  Indebetouw et al. (2005) show that the A/Ak for IRAC bands 2-4 are
;  identical. Consequently, they cannot all be used to determine Av
;  and are omitted from this procedure.
;
; CATEGORY:
;  catalog processing
;
; MODIFICATION HISTORY:
;  Written by: Chris Beaumont July 2008
;  November 2008: cnb. Updated to incorporate IRAC bands 1 and 2
;- 
function nicer, j, dj, h, dh, k, dk, i1, di1, i2, di2, color = color, covar = covar, status = status
compile_opt idl2

;- check inputs
if n_params() ne 10 then begin
    print, 'NICER calling sequence: '
    print, 'Av = NICER(j, dj, h, dh, k, dk, i1, di1, i2, di2)'
    return, -1
endif

sz = n_elements(j)
if (n_elements(dj) ne sz) || (n_elements(h) ne sz) || (n_elements(dh) ne sz) || $
  (n_elements(k) ne sz) || (n_elements(i1) ne sz) || (n_elements(di1) ne sz) || $
  (n_elements(i2) ne sz) || (n_elements(di2) ne sz) then message,'Input vectors must be the same size'

;- k=E/Av. (NOTE: E= (A1 - A2) by definition)
;- 2MASS values from Rieke and Lebofsky 1985
;- IRAC values from Indebetouw, Mathis et al. 2005 (Table 1, using
;- Ak/Av = .112 from Rieke and Lebofsky 1985)
Eav = dblarr(4)
Eav[0] = 0.106   ;- J-H
Eav[1] = 0.063   ;- H-K
Eav[2] = 0.049   ;- K-1
Eav[3] = 0.0146  ;- 1-2

;- Initial values for intrinsic colors
;- 2mass from j swift control field, IRAC from taurus field
if ~keyword_set(color) then $
  color = [.487419, .134643, .0556, .01707]

;- assemble the covariance matrices in eq 10.
cerr = dblarr(4,4, n_elements(j)) ;- the covariance error matrix
cerr[0,0,*] =  dj^2 + dh^2
cerr[0,1,*] = -dh^2
cerr[1,0,*] = -dh^2
cerr[1,1,*] =  dh^2 + dk^2
cerr[1,2,*] = -dk^2
cerr[2,1,*] = -dk^2
cerr[2,2,*] =  dk^2 + di1^2
cerr[2,3,*] = -di1^2
cerr[3,2,*] = -di1^2
cerr[3,3,*] =  di1^2 + di2^2

;- values for the intrinsic color scatter
;- the default values use a control field from taurus for irac
;- colors, and the field from js for 2mass colors

if ~keyword_set(covar) then $
  covar = [ [0.0280821,    0.00293,      0.00595462, -0.00233027],$
            [0.00293,      0.02765,      0.00320190,  0.000177188],$
            [0.00595462,   0.00320190,   0.00595323,  0.000593445],$
            [-0.00233027,  0.000177188,  0.000593445, 0.0257013] ]

cov = cerr + rebin(covar, 4, 4, n_elements(j))

;- invert the covariance matrix
ci = cov
status = intarr(n_elements(j))
for i = 0, n_elements(j)-1, 1 do begin
    ci[*,*,i] = invert(cov[*,*,i], stat, /double)
    status[i] = stat
endfor

;- solve equation 12
numer1 = reform(ci[0,0,*] * Eav[0] + ci[0,1,*] * Eav[1] + ci[0,2,*] * Eav[2] + ci[0,3,*] * Eav[3])
numer2 = reform(ci[1,0,*] * Eav[0] + ci[1,1,*] * Eav[1] + ci[1,2,*] * Eav[2] + ci[1,3,*] * Eav[3])
numer3 = reform(ci[2,0,*] * Eav[0] + ci[2,1,*] * Eav[1] + ci[2,2,*] * Eav[2] + ci[2,3,*] * Eav[3])
numer4 = reform(ci[3,0,*] * Eav[0] + ci[3,1,*] * Eav[1] + ci[3,2,*] * Eav[2] + ci[3,3,*] * Eav[3])
denom = Eav[0] * numer1 + Eav[1] * numer2 + Eav[2] * numer3 + Eav[3] * numer4

b1 = numer1 / denom
b2 = numer2 / denom
b3 = numer3 / denom
b4 = numer4 / denom

;- calculate Av from eq 13, and sigma from eq 9
av = b1 * ( (j-h) - color[0] ) + b2 * ( (h-k) - color[1] ) + b3 * ( (k-i1) - color[2]) + b4 * ((i1-i2) - color[3])
sv = sqrt(b1 * b1 * cov[0,0,*] + b1 * b2 * cov[0,1,*] + b1 * b3 * cov[0,2,*] + b1 * b4 * cov[0,3,*] + $
          b2 * b1 * cov[1,0,*] + b2 * b2 * cov[1,1,*] + b2 * b3 * cov[1,2,*] + b2 * b4 * cov[1,3,*] + $
          b3 * b1 * cov[2,0,*] + b3 * b2 * cov[2,1,*] + b3 * b3 * cov[2,2,*] + b3 * b4 * cov[2,3,*] + $
          b4 * b1 * cov[3,0,*] + b4 * b1 * cov[3,1,*] + b4 * b3 * cov[3,2,*] + b4 * b4 * cov[3,3,*])
sv = reform(sv,/over)

;-visually inspect
;plot,(h-k)-k2*av, (j-h)-k1*av,psym=3, xra=[-1.,2.5], yra=[-.5,3.],/xsty,/ysty
;oplot, [.188919], [.5007], psym=4, color='ff0000'xl
;oplot, (h-k), (j-h), color='00ff00'xl,psym=4

return,transpose([[av],[sv]])

end
