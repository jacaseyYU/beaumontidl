;+
; NAME:
;  getbubblemorph
;
; DESCRIPTION:
;  use the morphology catalog to return the morphology of a bubble
;-

function getbubblemorph, bubble
on_error, 2

readcol, '~/paper/cat/groupMorph.txt', num, morph, format='F,A', comment='#', /silent

hit = where(num eq bubble, ct)

if ct eq 0 then message, 'Bubble nto found in groupMorph.txt'

return, morph[hit[0]]

end
