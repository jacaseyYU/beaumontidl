;+
; PURPOSE:
;  This function partitions a list of values into its monotonic
;  sequences.
;
; INPUTS:
;  x: The table of values.
;  count: On output, will hold the numer of monotonic sequences.
;
; OUTPUTS:
;  A [2, nsequence] array, giving the first and last index of each
;  monotonic sequence. Each sequence begins at index 0 OR 1 index
;  after a local extremum, and continues through the next local extremum or
;  last index (inclusive).
;
; MODIFICATION HISTORY:
;  Jan 2011: Written by Chris Beaumont
;-
function monseq, x, count
  compile_opt idl2
  if n_params() lt 1 then begin
     print, 'calling sequence'
     print, 'result = monseq(x)'
     return, !values.f_nan
  endif

  nx = n_elements(x)
  if nx lt 3 then $
     message, 'x and y must have at least 3 elements'

  ;- define monotonic sequenes as starting _after_ a local extremum, 
  ;- and continuing to the next extremum (inclusive)
  ;- define the -1st and last pixel as exrema
  
  lo = shift(x, 1)
  hi = shift(x, -1)
  turn = (hi - x) * (x - lo) lt 0
  turn[0] = 1 & turn[nx-1] = 1

  hit = where(turn, ct) & hit[0] -= 1

  result = transpose( [[hit+1], [shift(hit, -1)]] )
  result = result[*, 0:ct-2]
  count = ct - 1
  return, result
end

pro test
  x = arrgen(0, 10, 1)
  y = x^2

  ms = monseq(y, ct)
  assert, ct eq 1
  assert, array_equal(ms, [0, 10])
 
  y = (x - 5)^2
  ms = monseq(y, ct)
  assert, ct eq 2
  assert, array_equal(ms, [[0, 5], [6, 10]])

end
