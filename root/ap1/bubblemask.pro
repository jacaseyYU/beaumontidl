;+
; NAME:
;  BUBBLEMASK
; 
; DESCRIPTION:
;  Claculates which pixels (l, b) are inside a given bubble
;
; INPUTS:
;  bubble: number of a bubble
;       l: longitudes
;       b: latitudes
;
; KEYWORDS:
;  HCOP: if set, use the HCO+ mask instead of the CO mask
;
; RESULTS:
;  A vector of 1s (inside a bubble) and 0s (outside a bubble) for each
;  (l,b) pair
;-

function bubblemask, bubble, l, b, HCOP = HCOP
compile_opt idl2
on_error, 2

;-short circuit for bubble 45 and HCO keyword
if keyword_set(hcop) && (bubble eq 45) then return, l * 0

;-read file
bubname = string(bubble, format='(i3.3)')
file = '/users/cnb/glimpse/pro/shells/saved/'

if keyword_set(hcop) then file = file+'/HCO/'+bubname+'H.sav' else $
  file = file+bubname+'.sav'

if ~file_test(file) then message, 'File not found: '+file
restore, file ;- restores shellmask and cast or hast
ast = keyword_set(hcop) ? hast : cast


;- translate l and b to pixel coordinates
x = (l - ast.crval[0]) / ast.cd[0,0] + ast.crpix[0] - 1
y = (b - ast.crval[1]) / ast.cd[1,1] + ast.crpix[1] - 1

sz = size(shellmask)
x = 0 > round(x) < (sz[1] - 1)
y = 0 > round(y) < (sz[2] - 1)


return, shellmask[x,y]

end
