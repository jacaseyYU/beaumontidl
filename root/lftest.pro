pro lumfunc, mv, phi

;- make a lum func

;- run parameters
nstars = 3d6
minage = .01   ;- Gyr old
maxage = 10   ;- Gyr old

masses = dblarr(nstars)
ages = dblarr(nstars)

;-mass cdf
masses = findgen(3d3) / 1d2 + 1d-2 ;- runs from .01 to 30 Msolar
imf = imf(masses)
mass_x = masses
mass_cdf = total(imf, /cumul) / total(imf)

;- random variables for objects
rand1 = randomu(seed, nstars)
rand2 = randomu(seed, nstars)

ages = minage + rand1 * (maxage - minage)
masses = interpol(mass_x, mass_cdf, rand2)

;- remove stars that have died
dead = where(masses^(-2.5) * 10 lt ages, deadct, complement = live)
if deadct ne 0 then begin
   ages = ages[live]
   masses = masses[live]
endif

;- convert stars to Mabs
mag = mass2magv(masses, ages)

;-remove things with magnitudes greater than 40
faint = where(mag gt 40, faintct, complement = bright)
if faintct ne 0 then begin
   ages = ages[bright]
   masses = masses[bright]
   mag = mag[bright]
endif

;- look at results
h = histogram(mag, loc = loc, binsize = .5)
;- smooth this a bit
h = convol(1.0 * h, [.1, .3, .8, .3, .1])
h = 1.0 * h / max(h)
plot, loc, h, yra = [0,1.15], psym = 10, thick = 2, $
      title = 'Luminosity Function', xtit = textoidl('M_V'), $
      ytit = textoidl('\Phi(M_V)'), charsize = 1.5, xra = [-5, 40], $
      /xsty, /ysty
top = max(h,hit)
print, loc[hit]

xyouts, 20, 1, 'Model (this work)', charsize = 1.5
xyouts, 20, .9, 'Empirical (Bochanski 2009)', color = fsc_color('crimson'), $
        charsize = 1.5

;-bochanski
val = [3, 2.1, 2, 2.1, 3, 3.5, 4, $
       5.2, 6.5, 7, 6.8, 5.8, $
       4.2, 3, 2.5, 2.8, 1.8, 1.5, $
       1, 1.8, .8, 1.5]
val /= max(val)
mag = findgen(n_elements(val)) / 2. + 6.5
oplot, mag, val, color = fsc_color('crimson'), psym = 10

phi = h
mv = loc
end
