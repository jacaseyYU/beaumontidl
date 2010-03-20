pro simpar_gen
;- simulate parallax fits for realistic luminosity functions

;- observing parameters
;mapp = 15    ;- only want things within 1 mag of this RELAXING THIS
nstars = 5d5 ;- number of objects generated per iteration 
minage = .01
maxage = 10

;- distances
dist = findgen(1d5) /10  ;- zero to 10kpc
pdist = dist^2D
dist_x = dist
dist_cdf = total(pdist, /cumul) / total(pdist)

theMasses = obj_new('stack')
theDists = obj_new('stack')
theAges = obj_new('stack')

iterate:

;- random number generation
rand1 = randomu(seed1, nstars)
rand3 = randomu(seed3, nstars)

ages = minage + rand1 * (maxage - minage)
masses = imf(random = nstars)
dists = interpol(dist_x, dist_cdf, rand3)

;- calculate absolute magnitudes
v = mass2mag(masses, ages, filter='v')

appv = v + 5 * alog10(dists / 10)

;- remove the dead stars, and the ones not of the right mag
bad = where(~finite(v) or appv gt 20, ct, complement = good, ncomp = ngood)
if ngood ne 0 then begin
   theMasses->push, masses[good]
   theAges->push,   ages[good]
   theDists->push,  dists[good]
endif

;- check to see if we have enough objects 
dists = theDists->toArray()
print, n_elements(dists), total(dists lt 500), format='("Collected ", i, " objects. ", i, " are closer than 500pc")'
wait, .1

if total(dists lt 500) le 1d4 then goto, iterate

;-save results
ages = theAges->toArray()
masses = theMasses->toArray()
dists = theDists->toArray()

obj_destroy, theAges
obj_destroy, theMasses
obj_destroy, theDists

;-calculate magnitudes
v = mass2mag(masses, ages, filter='v')
r = mass2mag(masses, ages, filter='r')
i = mass2mag(masses, ages, filter='i')
z = mass2mag(masses, ages, filter='z')
y = mass2mag(masses, ages, filter='y')
v = float(v)
r = float(r)
i = float(i)
z = float(z)
y = float(y)

;- save results
save, v, r, i, z, y, masses, dists, ages, file='simpar_gen.sav'

end

;- using a fake collection of stars, fake some observations to explore biases
pro simpar

file = 'simpar_gen.sav'
if ~file_test(file) then begin
   print, 'need to run simpar_gen first'
   return
endif

;- subselect only those at magnitude 15
mapp = 15
acc = 2 ;- parallax precision in mas

;- restores:
; vrizy, masses, dists, ages
restore, file
sz = n_elements(dists)
v = reform(rebin(v, sz, 3), sz * 3, /over)
i = reform(rebin(i, sz, 3), sz * 3, /over)
dists = reform(rebin(dists, sz, 3), sz * 3, /over)

;plot, v- i, v, psym = 3, yra = [12, -10]
vsim = v
visim = v - i

restore, 'colorgrid.sav'

vapp = vsim + 5 * alog10(dists / 10)
;plot, vsim, dists, psym = 3, /ylog, yra = [1d1, 1d4]

par_true = 1 / dists * 1d3 ;- mas
par_meas = par_true + acc * randomn(seed, n_elements(par_true)) ;- mas
sig = par_meas / acc

vabs_meas = vapp - 5 * alog10(1 / (par_meas * 1d-3) / 10)
;oplot, visim, vabs_meas, psym = 3, color = fsc_color('orange')
;oplot, visim, vsim, psym = 3
;oplot, v - i, v, psym = symcat(16), symsize = .3, color = fsc_color('blue')

;f = [1.0798, 4.00835]
;proj = abs(f[0] + f[1] * visim - vabs_meas)
;good = where(proj lt 2)


;bound_x = fltarr(40)
;bound_y = fltarr(40)
;nbound = 0
;while(1) do begin
;   cursor, x, y, /down, /data
;   if x lt -1 then break
;   bound_x[nbound] =  x
;   bound_y[nbound] = y
;   nbound++
;   oplot, [x], [y], color = fsc_color('blue'), psym = 4, symsize = 2
;endwhile
;bound_x = bound_x[0:nbound-1]
;bound_y = bound_y[0:nbound-1]
;save, bound_x, bound_y, file='cmd_bound.sav'
;oplot, bound_x, bound_y, color = fsc_color('blue')
;oplot, visim[good], vabs_meas[good], psym = 4, color = fsc_color('red')

;- plot significance, compare to gaussian
h = histogram(sig, binsize = .3, loc = loc)
exp =  1 / (sqrt(2 * !pi)) * total(h) * .3 * exp(-loc^2/2)
real = h - exp
confidence = real / h

plot, loc, confidence, charsize = 1.5, xra = [0,5], thick = 2

;-subset of observations that fall within the accepted cmd range
restore, 'cmd_bound.sav'
;- have to run inside in chunks
in = bytarr(n_elements(visim))
chunk = 1000
index = 0L
while (index lt n_elements(visim)) do begin
   lo = index
   hi = (index + chunk - 1) < (n_elements(visim)-1)
   in[lo:hi] = inside(visim[lo:hi], vabs_meas[lo:hi], bound_x, bound_y)
   index += chunk
endwhile

good = where(in, ct)
h2 = histogram(sig[good], binsize = .3, loc = loc2)
exp2 =  1 / (sqrt(2 * !pi)) * total(h2) * .3 * exp(-loc2^2/2)
confidence2 = (h2 - exp2) / h2
oplot, loc2, confidence2, thick = 2, color = fsc_color('green')
stop
return
;- restores vrizy, ages, masses
restore, 'colorgrid.sav'
vi_model = (v - i)
vmodel =  (v)
good = where(abs(vi_model) lt 10 and abs(vmodel) lt 20)
catalog = transpose([[vi_model[good]],[vmodel[good]]])
neighbor = nearestn(points, catalog, 0, dist = distances)

good = where(distances lt 1)
oplot, vi[good], vabs[good], psym = 3, color = fsc_color('red')
stop
;- show these results
;plot, vi, vabs, psym = 3
;oplot, vi_model, vmodel, psym = 3, color = fsc_color('red')
;oplot, vi[good], vabs[good], psym = 3, color = fsc_color('green')

end
