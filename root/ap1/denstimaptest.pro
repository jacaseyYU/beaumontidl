;+
; NAME:
;  DENSITYMAPTEST
;
; DESCRIPTION:
;  DEBUG density map procedure
;-

pro densitymaptest

restore, file='30.sav'

good = where(glimic.l le 30.2 and abs(glimic.b) le .1)

densitymap, glimic.l, glimic.b, 5, map, errmap, head, cdelt = 30 / 3600., /verbose, /robust
densitymap, glimic.l, glimic.b, 15, map2, errmap2, head, cdelt = 30 / 3600., /verbose, /robust
densitymap, glimic.l, glimic.b, 25, map2, errmap2, head, cdelt = 30 / 3600., /verbose, /robust

stop

end
