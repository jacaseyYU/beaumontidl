;+
; NAME:
;  newton1d
;
; PURPOSE: 
;  This function (kind of) does a newton's method descent to
;  find local minima of 1 dimensional functions. It approximates the
;  function's derivative maually.
;
; CATEGORY:
;  Optimization
;
; CALLING SEQUENCE:
;  result = newton1d(func, x, [tol, minvalue = minvalue, 
;                    scale = scale, range = range, /debug] )
;
; INPUTS:
;  func: A string naming the function to minimize. This function must
;  take as input a single scalar, and return a single scalar.
;     x: The starting point of the algorithm. Newton's
;     method descends down from X to find the nearest local minimima.
;   tol: The desired fractional precision of the returned minimum. 
;        In other words, the result should satisfy
;        f(xmin) < f(xmin +/- tol * xmin)       
;
; KEYWORD PARAMETERS:
;  MINVALUE: A variable to hold the value of f(xmin)
;  SCALE: The algorithm assumes that the function to minimize is
;  smooth on scales much smaller than 1 (i.e. the local minimum is
;  within a few units of x). If the scale of the problem is
;  substantially different, you should specify so with this keyword.
;  The value should be set conservatively low.
;  RANGE: A two element vector which brackets the search region - 
;         the search will never stray out of this region
;  DEBUG: If set, this will plot the progress of the algorithm.
;
; RETURNS:
;  The value x which minimizes f(x)
;
; MODIFICATION HISTORY:
;  Feb 2009: Written by CNB
;-
function newton1D, func, x, tol, $
                   minvalue = minvalue, $
                   scale = scale, $
                   debug = debug, $
                   range = range
compile_opt idl2
;on_error, 2

;- check inputs
if n_params() lt 2 then begin
   print, 'newtwon1D calling sequence:'
   print, 'result = newton1D(func, x, [tol, minvalue = minvalue,'
   print, '                  SCALE = scale, /DEBUG])'
   return, !values.f_nan
endif

if size(func,/type) ne 7 then $
   message, 'function must be a string'

;-define routine parameters
if n_params() eq 2 then TOL = 1d-5
if n_elements(scale) ne 1 then SCALE = 1D
if n_elements(range) ne 2 then begin
   range = !values.f_infinity * [-1, 1] 
endif else if range[1] lt range[0] then begin
   range[0] = junk
   range[0] = range[1]
   range[1] = junk
endif

MAXSTEP = 1000
GAMMA = 0.6D
DELT = SCALE / 1D2
TINY = 1d-7

;-starting values
x0 = x
x1 = x + DELT
x2 = x + 2 * DELT

f0 = call_function(func, x0)
f1 = call_function(func, x1)
f2 = call_function(func, x2)

;-rough derivative
fp = (f1 - f0) / DELT
fpp = (f2 - 2 * f1 + f0) / DELT^2

;- if the function is concave up, use parabolic interpolation. 
;- else, just step downhill
dx = (fpp gt 0) ? -fp / fpp : -SCALE * fp / abs(fp)
dx = (range[0] - x0) > dx < (range[1] - x0)

;-debugging plot
if keyword_set(DEBUG) then begin
   device, decomposed = 0
   loadct, 34, /silent
   if min(finite(range)) eq 1 then begin
      xs = findgen(100) / 99. * (range[1] - range[0]) + range[0]
   endif else begin
      xs = findgen(100) / 10. - 5. + x
   endelse

   ys = xs
   for i = 0, 99, 1 do  ys[i] = call_function(func, xs[i])
   plot, xs, ys, color = fsc_color('white'), background = fsc_color('black')
   oplot, [x0], [f0], color = fsc_color('crimson'), psym = 5, symsize = 2
endif

for i = 0, MAXSTEP - 1, 1 do begin
   if (x0 eq (x0 + GAMMA * dx)) then break ; underflow
   x0 = x0 + GAMMA * dx
   x1 = x0 + DELT * dx
   x2 = x0 + 2 * DELT * dx

   f0 = call_function(func, x0)
   f1 = call_function(func, x1)
   f2 = call_function(func, x2)

   fp = (f1 - f0) / (dx * DELT)
   fpp = (f2 - 2 * f1 + f0) / (dx * DELT)^2

   dx = fpp gt 0 ? - fp / (fpp + TINY) :  -fp / abs(fp) * SCALE
   dx = (range[0] - x0) > dx < (range[1] - x0)

   ;-debugging
   if keyword_set(debug) then begin
      oplot, [x0], [f0], color= 255. * i / MAXSTEP, psym = 5
      wait, .1
   endif

   if GAMMA * abs(dx) lt abs(x0) * tol then break
endfor

if (i eq MAXSTEP) then $
   message, 'Could not find the root in '+strtrim(string(MAXSTEP),2)+' steps'

result = x0
minvalue = f0

return, result

end

   
