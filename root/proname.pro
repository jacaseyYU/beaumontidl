;+
; PURPOSE:
;  proname returns the name of the function or procedure that
;  called proname. profound...
;
; OUTPUTS:
;  The name of the function that called proname
;
; MODIFICATION HISTORY:
;  June 2010: Written by Chris Beaumont
;-
function proname

  help, /trace, out = trace
  trace = trace[1]
  trace = scope_traceback(/struct)
  return, trace[n_elements(trace)-2].routine
end
