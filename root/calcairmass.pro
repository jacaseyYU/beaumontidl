pro driver
ms = file_search('/media/cave/catdir.[1-9]*/*/*.cpm', count = ct)
for i = 0, ct - 1, 1 do begin
   calcairmass, ms[i]
   stop
endfor
end

pro calcairmass, file

;-get some jds
npts = 3000

m = mrdfits(file,1,h, ra = [0, npts - 1])
t = mrdfits(strmid(file, 0, strlen(file)-1)+'t', 1, h, ra = [0,npts])

ra = replicate(median(t.ra), npts)
dec = replicate(median(t.dec), npts)

hisairmass = m.airmass+1

lat = 19.8244
lon = -155.473

jd = linux2jd(m.time)

eq2hor, ra, dec, jd, alt, az, ha, obsname='cfht';lat = lat, lon = lon
print, minmax(wrap(ha - 180, 360))
h = histogram(wrap(ha - 180, 360) / 15, binsize = .5, loc = loc)
!p.multi = [0,2,2]

plot, loc, h, psym = 10, charsize = 1.5, xtit = 'HA + 12h', title= file
plot, az, alt, psym = 3, charsize = 1.5, xtit = 'Az', ytit = 'Alt'


z = (90 - alt)*!dtor
x = 1/cos(z)

par_factor, ra[0], dec[0], jd, pR, pD
eq2hor, ra + pr / 36d3, dec + pD / 36d3, jd, alt2, az2, obsname = 'cfht'
plot, jd, x, psym = 3, charsize = 1.5, xtit = 'JD', ytit = 'airmass'
dx = (alt2 - alt) * 3600
dy = (az2 - az) * 3600
plot, dx, dy, psym = 3, charsize = 1.5, xra = [-1, 1], yra = [-1, 1]
end
