;+
; NAME:
;  sigclip
;
; DESCRIPTION:
;  This function sigma-clips a vector or array.
;
; CALLING SEQUENCE:
;  result = SIGCLIP( data, [thresh, NCLIP = nclip, NITER = niter])
;  
; INPUTS:
;  data: The vector or array to clip
;
; OPTIONAL INPUTS:
;  thresh: The sigma clipping threshhold. Default is 3.
;
; OUTPUT:
;   the subset of data such that:
;     abs(result - mean(result) ) < thresh * stdev(result).
;
; OPTIONAL OUTPUT KEYWORDS:
;  NCLIP: The number of data points that were removed
;  NITER: The number of iterations spent clipping
;
; MODIFICATION HISTORY:
;  January 2009 - Written by cnb.
;-

FUNCTION sigclip, data, thresh, NCLIP = nclip, NITER = niter
compile_opt idl2
on_error, 2

;- check inputs
if n_elements(data) le 3 then message, 'Input data must have 3 or more elements'
if n_elements(thresh) eq 0 then thresh = 3
if n_elements(thresh) gt 1 then message, 'thresh must be a scalar'
if (thresh) lt 0 then message, 'thresh must be > 0 : '+strtrim(string(thresh),2)


clip = data[where(finite(data), ct)]
if ct le 3 then message, 'Input data does not contain enough finite numbers'
niter = 0

;- iteratively clip
while (1) do begin
    niter++
    avg = mean(clip)
    sig = stdev(clip)
    good = where(abs(clip - avg) lt thresh * sig, goodct, nc = badct)
    if badct eq 0 then break;
    if (goodct eq 0) then message, 'Failure - clipped the entire dataset'
    clip = clip[good]
endwhile

;- return result
if KEYWORD_SET(nclip) then nclip = n_elements(data) - n_elements(clip)
return, clip

end
