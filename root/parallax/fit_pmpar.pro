;+
; PURPOSE:
;  This function fits parallax and proper motion to a set of
;  observations via chi-squared minimization.
;
; CALLING SEQUENCE:
;  result = fit_pmpar(jd, ra, dec, dra, ddec, [status, INCLUDED =
;  included, CLIP = clip, /VERBOSE])
;
; INPUTS:
;    jd: The julian dates for each observation
;    ra: The J2000 RA (in DEGREES) for each observation
;   dec: The J2000 Dec (in DETREES) for each observation
;   dra: The error in RA, in degrees
;  ddec: The error in declination, in degrees
;
; OPTIONAL INPUTS:
;  status: An integer to describe the results of the fit:
;          1: successful fit
;          0: failed fit
;
; KEYWORD PARAMETERS:
;  INCLUDED: A variable to hold an array of 1's and 0's. The
;  i'th index will be 1 if the ith input data point was used in
;  the fitting.
;  CLIP: If set and nonzero, perform outlier rejection. The fit will
;  iterate, rejecting outliers, until all points lie within CLIP *
;  uncertainty of the expected position.
;
;  VERBOSE: Print information during the procedure;
;
; OUTPUT:
;  A structure, containing the following fields:
;  RA       ---> The J2000 right ascension of the object on Jan 1, 2000
;  DEC      ---> The J2000 declination of the object on Jan 1, 2000
;  uRA      ---> The proper motion in RA, in mas / year
;  uDec     ---> The proper motion in DEC, in mas / year
;  parallax ---> The parallax, in mas
;  covar    ---> The variance / covariance matrix for the above parameters
;  chisq    ---> The chi-squared value of the fit
;  ndof     ---> The number of degrees of freedom in the fit (2 * number of
;              points used - 5)
;   
; MODIFICATION HISTORY
;  March 2009: Written by Chris Beaumont
;-  
function fit_pmpar, jd, ra, dec, $
                    dra, ddec, status, included = included, $
                    CLIP = clip, VERBOSE = verbose           
compile_opt idl2
;on_error, 2

;ISSUES
;- sigma clipping
;- report which points were fit

SUCCESS = 1
FAIL = 0
status = FAIL
MAX_REJ = 0.15

;- check inputs
if n_params() lt 5 || n_params() gt 6 then begin
   print, 'calling sequence:'
   print, 'result = fit_pmpar(jd, ra, dec, dra, ddec, [status, INCLUDED = included, '
   print, '                   CLIP = clip, /VERBOSE])'
   return, !values.f_nan
endif

sz = n_elements(jd)
if sz lt 3 then begin
   if keyword_set(verbose) then $
      message, 'Must have at least three epochs', /continue
   return, {parfit}
endif

if size(jd, /n_d) ne 1 || $
   size(ra, /n_d) ne 1 || $
   size(dec, /n_d) ne 1 || $
   size(dra, /n_d) ne 1 || $
   size(ddec, /n_d) ne 1 then $
      message, 'JD, ra, dec, dra, ddec must be 1D vectors'

if n_elements(ra) ne sz || $
   n_elements(dec) ne sz || $
   n_elements(dra) ne sz || $
   n_elements(ddec) ne sz then $
      message, 'jd, ra, dec, dra, and dec are not the same size'

if keyword_set(clip) && (clip le 0) then $
   message, 'The value for the CLIP keyword must be positive'

;XXX check for a valid range of parallax factors?

if min(jd) lt 2400000 then $
   message,  'JD outside acceptable range (may be reduced julian date)'

;-project observations onto a plane centered on the first coordinate
sxaddpar, coord, 'crval1', float(median(ra)) ;- why must these be floats??
sxaddpar, coord, 'crval2', float(median(dec))
sxaddpar, coord, 'cdelt1', 1D / 36D5
sxaddpar, coord, 'cdelt2', 1D / 36D5
sxaddpar, coord, 'crpix1', 1D 
sxaddpar, coord, 'crpix2', 1D
adxy, coord, ra, dec, x, y

;-calculte parallax factors
par_factor, median(ra), median(dec), jd, pX, pY
j2000 = 2451545.0D

;- keep track of which points we should use to fit
dofit = indgen(sz)

;- set up the least squares matrices
theFit:

t = (jd[dofit] - j2000) / 365.25 ;- time since J2000 in years
wx  = 1 / (dra[dofit]* 36D5)^2
wy  = 1 / (ddec[dofit] * 36D5)^2
xs  = wx * x[dofit]
ys  = wy * y[dofit]
pXs = pX[dofit]
pYs = pY[dofit]

A = dblarr(5,5)
A[0,0] = total(wx)
A[0,1] = total(wx * t)
A[0,4] = total(pXs * wx)

A[1,0] = total(wx * t)
A[1,1] = total(wx * t^2)
A[1,4] = total(wx * pXs * t)

A[2,2] = total(wy)
A[2,3] = total(wy * t)
A[2,4] = total(wy * pYs)

A[3,2] = total(wy * t)
A[3,3] = total(wy * t^2)
A[3,4] = total(wy * pYs * t)

A[4,0] = total(wx * pXs)
A[4,1] = total(wx * t * pXs)
A[4,2] = total(wy * pYs)
A[4,3] = total(wy * t * pYs)
A[4,4] = total(wx * pXs^2 + wy * pYs^2)

B = dblarr(5)
B[0] = total(xs)
B[1] = total(xs * t)
B[2] = total(ys)
B[3] = total(ys * t)
B[4] = total(xs * Pxs + ys * pYs)

error = invert(A, status, /double)
if status ne 0 then begin
   if keyword_set(VERBOSE) then $
      message, 'Array inversion failed', /continue
   status = FAIL
   return, {parfit}
endif

answer = error ## B

;-calculate chi-squared
fx = answer[0] + answer[1] * t + answer[4] * pXs
fy = answer[2] + answer[3] * t + answer[4] * pYs
chisq = total((x[dofit] - fx)^2  * wx) + $
        total((y[dofit] - fy)^2  * wy) 

;-outlier rejection
if keyword_set(clip) && (clip gt 0) then begin
   xoff = abs(x[dofit] - fx) * sqrt(wx)
   yoff = abs(y[dofit] - fy) * sqrt(wy)
   outlier = where((xoff gt clip) or (yoff gt clip), oct, $
                   complement = good, nc = ngood)

   if keyword_set(VERBOSE) then begin
      print, n_elements(x) - ngood, n_elements(x), $ 
             format= '("rejecting ", i3, " of ", i3, " points as outliers")'
   endif
   
   if ngood lt (1 - MAX_REJ) * sz then begin
      if keyword_set(VERBOSE) then $
         message, 'Too many points rejected as outliers',/continue
      status = FAIL
      return, {parfit}
   endif
      
   if ngood lt 3 then begin
      if keyword_set(VERBOSE) then $
         message, 'Not enough points to fit',/continue
      status = FAIL
      return, {parfit}
   endif

   dofit = dofit[good]
   if oct ne 0 then goto, theFit
endif

;-successful fit
status = SUCCESS

;- calculate the 1/0 included vector
included = bytarr(n_elements(x))
included[dofit] = 1B

;-project back from plane to sky
xyad, coord, answer[0], answer[2], ra_ans, d_ans

result = {parfit, $
          ra   : ra_ans, $
          ura  : answer[1], $
          dec  : d_ans, $
          udec : answer[3], $
          parallax  : answer[4], $
          covar : error, $
          chisq : chisq, $
          ndof : 2 * n_elements(dofit) - 5}

return, result
end
