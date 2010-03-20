pro avgaltest
;-map out outer glimpse survey - look for low extinction regions

restore, file='11.sav'
av = nicer_dev(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk, $
              glimic.mag1, glimic.dmag1, glimic.mag2, glimic.dmag2)
;av = nicer(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk)
good = where(av[0,*] le 80 and av[1,*] le 7)
l = glimic[good].l
b = glimic[good].b
ave = reform(av[1,good])
av = reform(av[0,good])

for i = 12, 63, 1 do begin
    print, i, format="('Reading file ', i2)"
    restore, file=string(i, format="(i2,'.sav')")
    av2 = nicer_dev(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk, $
                   glimic.mag1, glimic.dmag1, glimic.mag2, glimic.dmag2)
    ;av2 = nicer(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk)
        
    good = where(av2[0,*] le 80 and av2[1,*] le 7)
    l = [l, glimic[good].l]
    b = [b, glimic[good].b]
    av = [av, reform(av2[0,good])]
    ave = [ave, reform(av2[1,good])]
endfor

smoothmap, av, ave, l, b, map, emap, ctmap, head, /galactic, /verbose, out = 'galaxy'

stop

end
