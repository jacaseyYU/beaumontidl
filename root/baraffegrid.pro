pro baraffegrid

;- read in baraffe table of stellar evolution from .075 ->1Msol
;- save as idl variables

readcol, '~/idl/data/baraffe.tsv', $
         mh, y, lmix, mass, age, teff, g, mbol, v, r, i, j, h, k, $
         format = 'f, f, f, f, f, f, f, f, f, f, f, f, f, f', $
         comment='#', /silent

;- only care about solar composition
subset = where(mh eq 0 and y eq .275)

v = v[subset]
r = r[subset]
i = i[subset]
j = j[subset]
h = h[subset]
k = k[subset]
mass = mass[subset]
age = age[subset]

triangulate, mass, age, triangles

save, v, r, i, j, h, k, mass, age, triangles, file='~/idl/data/baraffe.sav'

end
