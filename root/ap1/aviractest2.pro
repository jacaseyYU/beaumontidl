;+
; NAME:
;  aviractest2
;
; PURPOSE:
;  Explore the differences between nicer (3 band 2mass) and
;  nicer_dev(5 band 2mass + irac) colors
;-

pro aviractest2

;-test data
restore, file = '20.sav'

;-clean test: all data is good. todo: relax this
tmassgood = (glimic.magh le 50) and (glimic.magj le 50) and (glimic.magk le 50)
iracgood = (glimic.mag1 le 50) and (glimic.mag2 le 50)

av1 = nicer(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk)
av2 = nicer_dev(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk, $
               glimic.mag1, glimic.dmag1, glimic.mag2, glimic.dmag2)

;- plot results where both should be good
;- there is a slight skew - measure this for consistency
plot, av1[0,where(iracgood and tmassgood)], av2[0, where(iracgood and tmassgood)], psym =3
oplot, [0,50],[0,50], color = fsc_color('green')


;-make avmaps
cut1 = where(tmassgood and (av1[1,*] le 7))
smoothmap, av1[0, cut1],av1[1,cut1],glimic[cut1].l, glimic[cut1].b, map, emap, ctmap, head,/verbose, fwhm = 1/60.

cut2 = where(av2[1,*] le 7)
smoothmap, av2[0,cut2], av2[1,cut2], glimic[cut2].l, glimic[cut2].b, map2, emap2, ctmap2, head,/verbose, fwhm = 1/60.


;- compare to clipping
smoothmap, av1[0, cut1],av1[1,cut1],glimic[cut1].l, glimic[cut1].b, map3, emap3, ctmap3, head3,/verbose, fwhm = 1/60., /clip
smoothmap, av2[0,cut2], av2[1,cut2], glimic[cut2].l, glimic[cut2].b, map4, emap4, ctmap4, head,/verbose, fwhm = 1/60., /clip

diff = map - map2

;- CONCLUSIONS:
;- Two maps agree well. Clipping definitely helps for smoother maps

stop

end
