pro explore

;if file_test('explore2.sav') then begin
;   restore, 'explore2.sav'
;   goto, readskip
;endif

restore, file='~/pro/chip.sav'
path = '/media/data/catdir.98/n0000/0148'
m = mrdfits(path+'.cpm',1,h)
t = mrdfits(path+'.cpt',1,h)
nt = n_elements(t)
info = replicate({meas_summary}, nt)
report = obj_new('looplister', nt-1, 10)
for i = 0L, nt-1, 1 do begin
   report->report,i
   lo = t[i].off_measure
   hi = lo + t[i].nmeasure-1
   if t[i].nmeasure lt 50 then begin
      info[i] = {meas_summary}
   endif else begin
      info[i] = analyze_measurements(t[i], m[lo:hi], chip)
   endelse
endfor
obj_destroy, report

save, m, t, info, file='explore.sav'
lo = t[900].off_measure
hi = lo + t[900].nmeasure-1
t = t[00:900]
info = info[00:900]
m = m[0:hi]
save, m,t,info, file='explore.test.sav'

readskip:

end
