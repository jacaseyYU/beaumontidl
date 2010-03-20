;+
; NAME:
;  getbubbledist
;
; DESCRIPTION:
;  Uses the distcat.txt file to return the near and far distances,
;  with error
;-

function getbubbledist, bubble
on_error, 2
if n_params() ne 1 then begin
    print, 'calling sequence: '
    print, 'result = getbubblevel(bubble)'
    print, 'returns, [vlo, vhi]'
    return, -1
endif

readcol, '/users/cnb/paper/cat/distcat.txt', num, dn, df, de,/silent

hit = where(bubble eq num, ct)
if ct eq 0 then message, 'Bubble not found in distcat.txt'
hit = hit[0]
return, [dn[hit],df[hit],de[hit]]


end

