pro maptest

restore, file='20.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50)
cat = glimic[good]

restore, file='21.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50)
cat = [cat,glimic[good]]

restore, file='22.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50)
cat = [cat, glimic[good]]

restore, file='23.sav'
good = where(glimic.magj le 50 and glimic.magh le 50 and glimic.magk le 50)
cat = [cat, glimic[good]]

glimic = cat

av = nicer(glimic.magj, glimic.dmagj, glimic.magh, glimic.dmagh, glimic.magk, glimic.dmagk)

good = where(av[1,*] le 5)

av = av[*, good]
glimic = glimic[good]

;print, 'starting map_av'
;map_av, map2, h2, emap2, ctmap2, glimic.l, glimic.b, av[0,*], av[1,*], cdelt=.2
;cdelt = sxpar(h2, 'cdelt2')

print, 'starting smoothmap'
t0 = systime(/seconds)
smoothmap, av[0,*], av[1,*], glimic.l, glimic.b, map, emap, ctmap, head, /galactic, /verbose
t1 = systime(/seconds)
print, t1 - t0

stop

sz = size(map2)
map = congrid(map, sz[1],sz[2])
good = where(finite(map2))
diff = map[good] - map2[good]

h = histogram(diff, loc=loc, binsize= .1)
plot, loc, h, psym=10

dim = map2
dim[*] = 0
dim[good] = diff
stop

end
