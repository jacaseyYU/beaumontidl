pro correlations

catch, theError
if (theError ne 0) then begin
   catch, /cancel
   print, 'Error!'
   obj_destroy, ms
   obj_destroy, as
   return
endif

meas = file_search('catdir.107/*/*.cpm')
avg = file_search('catdir.107/*/*.cpt')

images = mrdfits('catdir.107/Images.dat',1,/silent)

ms = obj_new('stack')
as = obj_new('stack')

for i = 0, n_elements(meas)-1, 1 do begin
   print, 'reading', i
   m = mrdfits(meas[i], 1, /silent)
   a = mrdfits(avg[i], 1, /silent)
   junk = as->push(a)
   junk = ms->push(m)
endfor
print, 'done'
m = ms->toArray()
a = as->toArray()
obj_destroy, ms
obj_destroy, as
catch,/cancel

good = where(finite(m.mag) and finite(m.d_ra) and (a[m.ave_ref].nmeas gt 1))
m = m[good]

h = histogram(m.image_id, loc = loc)
hit = where(m.image_id eq loc[(where(h eq max(h)))[0]])

m = m[hit]
plot, m.mag, m.d_ra, psym = 3


print, total(a.nmeas) / n_elements(a)
h = histogram(a.nmeas, loc = loc)
plot, loc, alog10(h), psym = 10
stop
end
