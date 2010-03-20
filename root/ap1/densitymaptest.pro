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
glimic = glimic[good]

densitymap, glimic.l, glimic.b, 15, map, errmap, head, cdelt = 5 / 3600., /verbose
print,''
densitymap, glimic.l, glimic.b, 25, map2, errmap2, head, cdelt = 5 / 3600., /verbose
densitymap, glimic.l, glimic.b, 45, map3, errmap3, head, cdelt = 5 / 3600., /verbose

top = median(map3) + 3 * stdev(map3)

tvblink, (map<top) / top * 255, (map2<top) / top * 255, (map3<top) / top * 255

stop

end
