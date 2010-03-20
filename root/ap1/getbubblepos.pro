;+
; NAME:
; getBubblePos
;
; DESCRIPTION:
;  Uses the bubble CO shellmasks to determine where in space a bubble
;  lies
;
; INPUTS:
;  Bubble, the number of the bubble for which a CO file exists
;
; RETURNS:
;  [ [ l_min,    l_max],
;     [ b_min,    b_max] ]
function getBubblePos, bubble
on_error, 2

if n_params() eq 0 then begin
    print, 'getBubblePos calling sequence:'
    print, 'result = getBubblePos(bubble)'
    print, 'returns [min(l), max(l),'
    print, '         min(b), max(b)]'
    return, -1
endif

maskfile = '/users/cnb/glimpse/pro/shells/saved/'+string(bubble,format='(i3.3)')+'.sav'
if ~file_test(maskfile) then message, 'cant find file '+maskfile

restore, maskfile
lon = (findgen(cast.sz[0]) + 1 - cast.crpix[0]) * cast.cd[0,0] + cast.crval[0]
lat = (findgen(cast.sz[1]) + 1 - cast.crpix[1]) * cast.cd[1,1] + cast.crval[1]

result = fltarr(2,2)
result[*,0] = minmax(lon)
result[*,1] = minmax(lat)

return, result

end 


