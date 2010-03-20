pro bastigrid
;-convert BaSTI grids for solar abundance into a set of idl arrays

catch, theError
if (theError ne 0) then begin
   catch,/cancel
   message, /continue, !error_state.msg
   goto, cleanup
endif

files = file_search('~/idl/data/basti_solar/*')
if n_elements(files) eq 0 then begin
   print, 'files not found'
   return
endif

mass = obj_new('stack')
age  = obj_new('stack')
u    = obj_new('stack')
b    = obj_new('stack')
v    = obj_new('stack')
r    = obj_new('stack')
i    = obj_new('stack')
j    = obj_new('stack')
h    = obj_new('stack')
k    = obj_new('stack')
l    = obj_new('stack')

cutoffmass = dblarr(n_elements(files))
cutoffage = dblarr(n_elements(files))

for m = 0, n_elements(files) -1 , 1 do begin
   readcol, files[m], $
            theage, themass, lum, temp, magv, ub, bv, vi, vr, vj, vk, vl, hk, $
            format = 'f, f, f, f, f, f, f, f, f, f, f, f, f', $
            delimiter = ' ', comment='#', /silent
   
   ;- calculate magnitudes
   magb = magv + bv
   magu = magb + ub
   magr = magv - vr
   magi = magv - vi
   magj = magv - vj
   magk = magv - vk
   magh = magk + hk
   magl = magv - vl

   ;- parse mass
   temp = strsplit(files[m],'/',/extract)
   themass = strmid(temp[n_elements(temp)-1], 0, 4)
   themass = float(themass) / 100
   
   mass->push, magb * 0 + themass
   age->push, theage
   u->push, magu
   b->push, magb
   v->push, magv
   r->push, magr
   i->push, magi
   j->push, magj
   h->push, magh
   k->push, magk
   l->push, magl
   cutoffmass[m] = themass
   cutoffage[m] = max(theage)
endfor

masses = mass->toArray()
ages = age->toArray()
us = u->toArray()
bs = b->toArray()
vs = v->toArray()
rs = r->toArray()
is = i->toArray()
js = j->toArray()
hs = h->toArray()
ks = k->toArray()
ls = l->toArray()

;- perform triangulation for future interpolation
triangulate, masses, ages, triangles
save, masses, ages, $
      cutoffmass, cutoffage, $
      us, bs, vs, rs, is, js, hs, ks, ls, triangles, file='~/idl/data/basti.sav'

cleanup:
if obj_valid(mass) then obj_destroy, mass
if obj_valid(age) then obj_destroy, age
if obj_valid(u) then obj_destroy, u
if obj_valid(b) then obj_destroy, b
if obj_valid(v) then obj_destroy, v
if obj_valid(r) then obj_destroy, r
if obj_valid(i) then obj_destroy, i
if obj_valid(j) then obj_destroy, j
if obj_valid(h) then obj_destroy, h
if obj_valid(k) then obj_destroy, k
if obj_valid(l) then obj_destroy, l

end
