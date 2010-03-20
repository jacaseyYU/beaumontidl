pro trapeziumSim

;-simulate trapezium like cluster in N021

;- info on bubble
l = 18.190
b = -.396
d = 3.7                         ;distance in kpc
av = 20

;-approximation to Orion K-band IMF
dx = 5/60.                      ;size of FOV in degrees
dori = .4                       ;distance in kpc
kmag = findgen(12)/2.+4.
logn = .5 + 1/2.8 * (kmag-6.75)

;-transform quantities to bubble
dx *= (dori/d)
kmag += (2.5 * alog10((d/dori)^2.) )
n = 10^logn


;-read in catalog. Select entries wthin a 10' box
restore, file='18.sav'
inside = where(abs(glimic.l - l) le 10./60. and abs(glimic.b - b) le 10./60.,ct)
if ct eq 0 then stop

;- synthesized starfield
starfield = fltarr(700, 700)
cd = 1/3600.
realxpos = (glimic[inside].l-l) / cd + 350
realypos = (glimic[inside].b-b) / cd + 350
realmag = glimic[inside].magk

nobad = where(realmag le 90, ct2)
if ct eq 0 then stop

realxpos=realxpos[nobad]
realypos=realypos[nobad]
realmag=realmag[nobad]

starfield[realxpos,realypos] += 10^(-realmag/2.5)

;-populate with fake stars
fakestarfield = fltarr(700,700)

for i=0, n_elements(kmag)-1, 1 do begin
    nfake = round(total(n[i]))>1
    if nfake lt 1 then continue
    fakex = (randomu(seed,nfake)-.5)*dx/cd + 350
    fakey = (randomu(seed,nfake)-.5)*dx/cd + 350
    fakei = 10^(-kmag[i]/2.5)
    fakestarfield[fakex,fakey]+=fakei
endfor

;-convolve with seeing of 2mass
psf=psf_gaussian(npixel=15, fwhm=3)

starfield = convolve(starfield, psf)
fakestarfield = convolve(fakestarfield, psf)

;-region of shell
readcol,'~/analysis/reg/021_sh_1.reg', lon, lat
lat = (lat-b)/cd + 350
lon = (lon-l)/cd + 350

lat=[lat,lat[0]]
lon=[lon,lon[0]]

tvscl, sigrange(starfield+fakestarfield, fraction=.99)
plots, lon, lat, /device

stop
end
