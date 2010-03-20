pro nicer_test

restore, file='50.sav'

good = (glimic.dmagj le 50)
glimic.magj = (glimic.magj) * good

good = (glimic.dmagh le 50)
glimic.magh = (glimic.magh) * good

good = (glimic.dmagk le 50)
glimic.magk = (glimic.magk) * good

good = (glimic.dmag1 le 50)
glimic.mag1 = (glimic.mag1) * good

good = (glimic.dmag2 le 50)
glimic.mag2 = (glimic.mag2) * good


;-test 1- use all data, see if flagging works
av1 = nicer_dev(glimic.magJ, glimic.dmagJ, glimic.magH, glimic.dmagH, $
            glimic.magK, glimic.dmagK, glimic.mag1, glimic.dmag1, $
            glimic.mag2, glimic.dmag2)

;-use only jhk on new nicer - see if it works
nelem = n_elements(glimic.magJ)
mag = fltarr(nelem)
err = fltarr(nelem) + 500
av2 = nicer_dev(glimic.magJ, glimic.dmagJ, glimic.magH, glimic.dmagH, $
            glimic.magK, glimic.dmagK, mag, err, mag, err)

;-use only jhk wiht old nicer - check for agreement
av3 = nicer(glimic.magJ, glimic.dmagJ, glimic.magH, glimic.dmagH, $
            glimic.magK, glimic.dmagK)

;- seemts to work decently, but should check with a map

map_av, avmap1, h1, avemap1, ns1, glimic.l, glimic.b, av1[0,*], av1[1,*], $
  cdelt = .05, avmax = 30

end
