;+
; PURSPOSE:
;  This is an internal function to c2noncen_cdf. It helps to vectorize
;  that process.
;
; INPUTS:
;  Result: The running value of c2noncen_cdf
;  j0: The first term in the sum that was evaluated
;  offset: How many indices (on each side of j0) have been evaluated.
;  x: The input x value
;  f: The input f value
;  status: The status vector
;
; OUTPUTS:
;  The final value of c2noncen_cdf. This function may call itself.
;
; MODIFICATION HISTORY:
;  Feb 2010: Written by Chris Beaumont
;-
function c2noncen_recurse, result, j0, offset, x, lambda, f, status
  compile_opt idl2, hidden

  eps = 1d-40
  jmin = 20
  jmax = 500

  ;- add1 is automatically zero for negative terms in the sum
  add1 = poisson_pdf(j0 - offset, lambda / 2D) * $
      chisqr_pdf(x, f + 2 * (j0 - offset))
  add2 = poisson_pdf(j0 + offset, lambda / 2D) * $
         chisqr_pdf(x, f + 2 * (j0 + offset))
  
  ;- check for floating point exceptions
  bad = where(~finite(add1 + add2), ct)
  if ct ne 0 then status[bad] = 1

  ;- check for non-convergence
  if offset eq jmax then begin
     status[*] = 2
     return, result + add1 + add2
  endif

  ;- automatically take another step if we haven't added enough terms yet
  if offset le jmin then $
     return, c2noncen_recurse(result + add1 + add2, j0, offset + 1, x, lambda, f, status)

  ;- check for convergence
  todo = where((add1 + add2) ge eps, todoct)
  new = result + add1 + add2
  ;- recurse on non-converged inputs
  if todoct ne 0 then begin
       s = bytarr(todoct)
       new[todo] = c2noncen_recurse(new[todo], j0[todo], $
                                    offset + 1, x[todo], $
                                    lambda[todo], f[todo], s)
       status[todo] = s
    endif
  return, new
end  
