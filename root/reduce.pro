;- filter, flag, fit parallax to data

pro reduce, dir = dir, path = path, bin = bin, cv = cv

if file_test(dir + path + (keyword_set(bin) ? '.bin.sav' : '.sav')) then begin
   print, 'already reduced '+dir+path
   return
endif


MIN_MEASURE = 45

t = mrdfits(dir + path+'.cpt',1,h)

if ~file_test(dir+path+'.skymodel') then begin
   print, 'no skymodel for '+path
   return
endif

restore, dir+path+'.skymodel'

;- sort catalog by number of measurements
sort = reverse(sort(t.nmeasure))
t = t[sort]
sub = where(t.nmeasure ge MIN_MEASURE, subct)
if subct eq 0 then begin
   print, 'no objects with at least '+string(min_measure)+' measurements. Aborting'
   return
endif
t = t[sub]

nt = n_elements(t)
nm = total(t.nmeasure)


;-relevant data to track
;flags = intarr(nm) - 1
cv = keyword_set(cv) ? cv : 1
pos = replicate({posfit}, cv, nt)
pm = replicate({pmfit}, cv, nt)
par = replicate({parfit}, cv, nt)
obj_flags = intarr(nt)
mags = fltarr(4, nt) * !values.f_nan
temp = mrdfits(dir + path+'.cpm', 1, h, range = [0,1], /silent)
flags =  intarr(sxpar(h, 'naxis2')) + '100'xl

report = obj_new('looplister', nt, 30)
for i = 0L, nt - 1, 1 do begin
   report->report, i
   lo = t[i].off_measure
   hi = t[i].nmeasure - 1 + lo

   
   ;- load measurements
   m = mrdfits(dir+path+'.cpm',1,h,range=[lo,hi],/silent)
   xerr = dx[lo:hi]
   yerr = dy[lo:hi]
   
   reduce_object, m, t[i], $
                  xerr, yerr, $
                  ofl, fl, mag, i_pos, i_pm, i_par, bin = bin, cv = cv
   assert, max((abs(m.d_ra) gt 1) and (fl eq 0)) eq 0
   assert, max((abs(m.d_dec) gt 1) and (fl eq 0)) eq 0
   assert, n_elements(fl) eq n_elements(m)
   flags[lo:hi] = fl
   mags[*,i] = mag
   obj_flags[i] = obj_flags[i] or ofl
   pos[*,i] = i_pos
   pm[*,i] = i_pm
   par[*,i] = i_par
endfor 

;-save out results
obj_destroy, report
file = dir + path + (keyword_set(bin) ? '.bin.sav' : '.sav')
save, obj_flags, flags, pos, pm, par, mags, t, file = file

;- save out the good results in a smaller file
subfile = dir + path + (keyword_set(bin) ? '.bin.good.sav' : '.good.sav')
PAR_FIT = '400'xl
cat_id = where((obj_flags and PAR_FIT) ne 0, gct)
if gct eq 0 then return

pos = pos[*, cat_id]
pm = pm[*, cat_id]
par = par[*, cat_id]
mags = mags[*, cat_id]
obj_flags = obj_flags[cat_id]
t = t[cat_id]

save, flags, cat_id, obj_flags, pos, pm, par, mags, t, file = subfile

  
end
