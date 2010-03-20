;+
; NAME:
;  getbubblevel
;
; DESCRIPTION:
;  Uses the bubblemomentmap.txt file to return the low and high
;  velocities for a bubble
;-

function getbubblevel, bubble
on_error, 2
if n_params() ne 1 then begin
    print, 'calling sequence: '
    print, 'result = getbubblevel(bubble)'
    print, 'returns, [vlo, vhi]'
    return, -1
endif

readcol, '/users/cnb/glimpse/pro/bubblemomentmap.txt', num, vlo, vhi, /silent

hit = where(bubble eq num, ct)
if ct eq 0 then message, 'Bubble not found in bubblemomentmap.txt'
return, [vlo[hit[0]], vhi[hit[0]]]

end

