;+
; PURPOSE:
;  This function uses a binary search to find solve f(x) = y for x,
;  given y.
;
; CATEGORY:
;  numerical recipes
;
; INPUTS:
;  func: The string name of the function to solve for. This function
;  must accept a scalar value x and return a scalar y = f(x). The
;  function must accept the _extra keyword. The function can define
;  additional keywords and, if these are provided by the user in a
;  call to bsearch, they will be passed along to function calls;
;  lo: A guess for x which brackets the desired y on one side
;  hi: A guess for x which brackets the desired y on the other side
;  value: The value of y to solve for. If not provided, defaults to 0
;
; KEYWORD PARAMETERS:
;  precision: The precision to which x is determined
;  yprecision: The precision to which y is determined
;  _extra: Any extra keywords will be passed along to calls to func
;
; OUTPUTS:
;  The approximate value of x for which f(x) = val. 
;
; MODIFICATION HISTORY:
;  November 2009: Written by Chris Beaumont
;-
function bsearch, func, lo, hi, value, _extra = extra, precision = precision
  compile_opt idl2
  on_error, 2

  ;- check inputs
  npar = n_params()
  if npar lt 3 || npar gt 4 then begin
     print, 'calling sequence:'
     print, ' result = bsearch(func, lo, hi, [value, _extra = extra, precision = precision])'
     return, !values.f_nan
  endif

  ;- default values for value and precision
  if n_params() eq 3 then value = 0
  if ~keyword_set(precision) then precision = 1d-3
  if ~keyword_set(yprecision) then yprecision = !values.f_infinity
  
  if lo eq hi then message, 'lo and hi must not be equal'
  if lo gt hi then swap, lo, hi

  flo = call_function(func, lo, _extra = extra) - value
  fhi = call_function(func, hi, _extra = extra) - value
  if flo eq 0 then return, lo
  if fhi eq 0 then return, hi

  if flo * fhi ge 0 then message, 'provided bracket points may not bracket value'
  
  mid = lo + (hi - lo) / 2D
  while (hi - lo) gt precision || abs(fhi - flo) gt yprecision do begin
     mid = lo + (hi - lo) / 2D
     fmid = call_function(func, mid, _extra = extra) - value
     if fmid eq 0 then return, mid
     ;- lo and mid bracket the minimum. mid is the new hi
     if fmid * flo lt 0 then begin
        hi = mid
        fhi = fmid
     ;- mid and hi bracket the new minimum. mid is the new lo   
     endif else begin
        lo = mid
        flo = fmid
     endelse
  endwhile

  return, mid
end
