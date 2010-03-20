function constrained_min, func, p0, $
                          lobound = lobound, hibound = hibound, tol = tol, $
                          niter = niter, verbose = verbose, $
                          _extra = extra 

  debug = 1

  ;- algorithmic magic numbers
  maxiter = 60
  eps = 1d-4
  grow = 1.1

  if ~keyword_set(tol) then tol = .01
  nparam = n_elements(p0)

  success = 0
  bestguess = p0
  guess = p0
  val = call_function(func, bestguess, dp, _extra = extra)
  if total(finite(dp)) ne n_elements(dp) then stop

  nstep = 0

  for niter = 0, maxiter - 1, 1 do begin
     yes = 1
     step = -dp / sqrt(total(dp^2))
     stepsize = tol / sqrt(nparam) * .1
     
     oldguess = bestguess
     guess = bestguess
    
     ;- step in a straight line, in increasingly large steps, until 
     ;- f(x) starts to increase again
     while (yes) do begin
                
        ;if keyword_set(debug) then print, 'guess and val:', guess, val
        ;print, 'stepsize: ', stepsize
        bestguess = guess
        guess += step * stepsize
        nstep++
        
        ;- stay inside the boundary
        for i = 0, nparam - 1, 1 do begin
           if finite(lobound[i]) then guess[i] = guess[i] > (lobound[i])
           if finite(hibound[i]) then guess[i] = guess[i] < (hibound[i])
        endfor

        if total( (guess - bestguess)^2) eq 0 then begin
           if keyword_set(verbose) then print, 'hit a corner'
           return, guess
        endif

        newval = call_function(func, guess, dp, _extra = extra)
        if ~finite(newval) || total(finite(dp)) ne n_elements(dp) then begin
           if keyword_set(verbose) then print, 'f(x) diverged'
           stop
           return, !values.f_nan
        endif
        
        if keyword_set(verbose) then print, newval
        ;- update stepsize
        stepsize *= grow
        
        ;- do we need to turn around?
        yes = (newval le val)
        val = newval
        
     endwhile

     
    ;-  we have converged if we moved
    ;  less than tol from the last max
     delt = sqrt(total((bestguess - oldguess)^2))
     if delt lt tol then begin
        success = 1
        break
     endif
     
     if keyword_set(verbose) then begin
        print, 'Finished iteration '+strtrim(niter)
        print, 'f(x_best): ', val
        print, 'x_best: ', bestguess
        print, 'nsteps: ', strtrim(nstep)
        print, 'total movement: ', string(delt, format='(e9.2)')
     endif
  endfor

  if ~success then begin
     if keyword_set(verbose) then print, 'failure to converge'
     return, !values.f_nan
  endif

  return, guess
end
  
