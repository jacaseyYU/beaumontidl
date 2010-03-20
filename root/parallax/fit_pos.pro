;+
; PURPOSE:
;  This function calculates the average position of an object based on
;  a set of measurements.
;
; CALLING SEQUENCE:
;  result = fit_pos(ra, dec, dra, ddec, [status, CLIP = clip, /VERBOSE])
;
; INPUTS:
;    ra: The J2000 RA (in DEGREES) for each observation
;   dec: The J2000 Dec (in DETREES) for each observation
;
; OPTIONAL INPUTS:
;  status: An integer to describe the results of the fit:
;          1: successful fit
;          0: failed fit
;
; KEYWORD PARAMETERS:
;  CLIP: If set and nonzero, perform outlier rejection. The fit will
;  iterate, rejecting outliers, until all points lie within CLIP *
;  uncertainty of the expected position.
;
;  VERBOSE: Print information during the procedure;
;
; OUTPUT:
;  A structure, containing the following fields:
;  RA       ---> The J2000 right ascension of the object on Jan 1, 2000
;  dra      ---> The error on the right ascension
;  DEC      ---> The J2000 declination of the object on Jan 1, 2000
;  ddec     ---> The error on the declination
;  chisq    ---> The chi-squared value of the fit
;  ndof     ---> The number of degrees of freedom in the fit (2 * number of
;              points used - 2)
;   
; MODIFICATION HISTORY
;  May 2009: Written by Chris Beaumont. Adapted from fit_pmpar
;-  
function fit_pos, ra, dec, $
                 dra, ddec, status, included = included, CLIP = clip, VERBOSE = verbose           
compile_opt idl2
;on_error, 2
SUCCESS = 1
FAIL = 0
status = FAIL
MAX_REJ = 0.15

;- check inputs
if n_params() lt 4 || n_params() gt 5 then begin
   print, 'calling sequence:'
   print, 'result = fit_pos(ra, dec, dra, ddec, [status, CLIP = clip, /VERBOSE, included = included])'
   return, !values.f_nan
endif

sz = n_elements(ra)
if sz lt 2 then begin
   if keyword_set(verbose) then $
      message, 'Must have at least two epochs', /continue
   return, {posfit}
endif

if size(ra, /n_d) ne 1 || $
   size(dec, /n_d) ne 1 || $
   size(dra, /n_d) ne 1 || $
   size(ddec, /n_d) ne 1 then $
      message, 'ra, dec, dra, ddec must be 1D vectors'

if n_elements(dec) ne sz || $
   n_elements(dra) ne sz || $
   n_elements(ddec) ne sz then $
      message, 'ra, dec, dra, and dec are not the same size'

if keyword_set(clip) && (clip le 0) then $
   message, 'The value for the CLIP keyword must be positive'

;- keep track of which points we should use to fit
dofit = indgen(sz)

;- set up the least squares matrices
theFit:

x = wmean(ra[dofit], dra[dofit], error = dx, /nan)
y = wmean(dec[dofit], ddec[dofit], error = dy, /nan)

;-calculate chi-squared
chisq = total( ((ra[dofit] - x) * cos(y * !dtor))^2 / dra[dofit]^2 + $
               (dec[dofit] - y)^2 / ddec[dofit]^2, /nan)

;-outlier rejection
if keyword_set(clip) && (clip gt 0) then begin
   xoff = abs(ra[dofit] - x) * cos(y * !dtor) / dra[dofit]
   yoff = abs(dec[dofit] - y) / ddec[dofit]
   outlier = where((xoff gt clip) or (yoff gt clip), oct, $
                   complement = good, nc = ngood)

   if keyword_set(VERBOSE) then begin
      print, n_elements(dofit) - ngood, n_elements(dofit), $ 
             format= '("rejecting ", i3, " of ", i3, " points as outliers")'
   endif
   
   if ngood lt (1 - MAX_REJ) * sz then begin
      if keyword_set(verbose) then $
         message, 'Too many points rejected as outliers',/continue
      status = FAIL
      return, {posfit}
   endif
      
   if ngood lt 2 then begin
      if keyword_set(verbose) then $
         message, 'Not enough points to fit',/continue
      status = FAIL
      return, {posfit}
   endif

   dofit = dofit[good]
   if oct ne 0 then goto, theFit
endif

;-successful fit
status = SUCCESS

;- calculate the 1/0 included vector
included = bytarr(n_elements(ra))
included[dofit] = 1B

result = {posfit, $
          ra   : x, $
          dra  : dx, $
          dec  : y, $
          ddec : dy, $
          chisq : chisq, $
          ndof : 2 * n_elements(dofit) - 2}
return, result

end
