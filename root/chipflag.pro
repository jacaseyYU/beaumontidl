pro chipflag

path = '/media/data/catdir.98/'

ms = file_search(path+'*/*.cpm')
ts = file_search(path+'*/*.cpt')
im = mrdfits(path+'Images.dat',1,h,/silent)
nimage = n_elements(im)
chip = bytarr(nimage+1)
for i = 0, n_elements(ms)-1, 1 do begin
   m = 0
   t = 0
   m = mrdfits(ms[i],1,h)
   t = mrdfits(ts[i],1,h,/silent)
   h = histogram(m.image_id, loc = loc, reverse = ri)
   report = obj_new('looplister', n_elements(loc)-1, 5)
   for j = 0L, n_elements(loc)-1, 1 do begin
      report -> report, j
      if ri[j+1] eq ri[j] then continue
      match = ri[ri[j] : ri[j+1]-1]
      subm = m[match]
      assert, range(subm.photcode) eq 0
      ;- U images are bad
      if (subm[0].photcode / 100) eq 1 then continue 
      good = where((subm.phot_flags and 14472) eq 0 and (t[subm.ave_ref].nmeasure gt 30) ,gct, $
                complement = bad, ncomp = bct)
      ;- require >3x as many good objects as bad objects
      if gct / bct lt 3 then continue
      ;- flag as good
      chip[subm[0].image_id] = 1B
   endfor
   obj_destroy, report
endfor

save, chip, file='chip.sav'

end
