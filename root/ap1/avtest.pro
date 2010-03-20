pro avtest

file = 'control.dat'
readcol, file, ra, dec, j, dj, h, dh, k, dk

plot, h - k, j - h, psym = 3, xra = [-.5, 3.0], yra = [-.5, 3.0], /xsty, /ysty

;avcontrol, transpose([[j],[h],[k]]), color, covar

readcol, 'G028.53.Av.dat', ra, dec, j, dj, h, dh, k, dk, av, dav, skipline=1

myav = nicer(j, dj, h, dh, k, dk)
;get_av, jav, javerr

;map_av, jmap, jh, jemap, jctmap, cdelt = .5
;cdelt = sxpar(jh, 'cdelt2')
;fwhm = 2 * sqrt(2 * alog(2)) * cdelt

smoothmap, myav[0,*], myav[1,*], ra, dec, map, emap, ctmap, head, /verbose, out = 'no_clip'
smoothmap, myav[0,*], myav[1,*], ra, dec, map, emap, ctmap, head, /verbose, out = 'clip', /clip


;smoothmap, myav[0,*], myav[1,*], ra, dec, map2, emap2, ctmap2, head2, /clip, /verbose, cdelt = cdelt, fwhm = fwhm
;smoothmap, myav[0,*], myav[1,*], ra, dec, map, emap, ctmap, head, cdelt = cdelt, fwhm = fwhm, /verbose


good = where(finite(jmap) and finite(map))
diff = jmap[good] - map[good]
h = histogram(diff, loc=loc, binsize=.1)
plot, loc, h, psym=10

stop
return

file = '/users/cnb/glimpse/pro/2mass_orion.txt'

openr, 1, file
skip_lun, 1, 71, /lines

a = ''
ra = fltarr(24329)
dec = ra
j = ra
dj = ra
h = ra
dh = ra
k = ra
dk = ra

i = 0L
while ~eof(1) do begin
    readf, 1, a
    split = strsplit(a,' ',/extract)
    if split[23] ne '000' then continue
    ext = split[[0,1,8,10,12,14,16,18]]
    bad = where(ext eq 'null', ct)
    if ct ne 0 then continue

    ra[i]  = float(split[0])
    dec[i] = float(split[1])
    j[i]   = float(split[8])
    dj[i]  = float(split[10])
    h[i]   = float(split[12])
    dh[i]  = float(split[14])
    k[i]   = float(split[16])
    dk[i]  = float(split[18])
    i++
endwhile

close, 1

ra = ra[0:i-1]
dec = dec[0:i-1]
j = j[0:i-1]
dj = dj[0:i-1]
h = h[0:i-1]
dh = dh[0:i-1]
k = k[0:i-1]
dk = dk[0:i-1]

save, ra, dec, j, dj, h, dh, k, dk, file = 'avtest.sav'

;-get avs
av = nicer(j, dj, h, dh, k, dk)

good = where(av[1,*] le 5, ct)
print, n_elements(av[0,*]), ct

ra = ra[good]
dec = dec[good]
av = av[*,good]

smoothmap, av[0,*], av[1,*], ra, dec, map, errmap, ctmap, head, fwhm = 5/60., cdelt = 2.5/60.

stop

end
