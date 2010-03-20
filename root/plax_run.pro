;+
; run through catdir.98, run pm and parallax fitting on detections,
; and save the results for analysis
;-
pro plax_run

path = '/media/data/catdir.98/'
ts = file_search(path+'*/*.cpt', count = ct)
ms = file_search(path+'*/*.cpm', count = mct)
assert, mct eq ct

;- set up data structures
mag = obj_new('stack')
rms = obj_new('stack')
myrms = obj_new('stack')
parallax = obj_new('stack')

entry = {entry, cpm:'',  $               ;- path of the .cpm file for this object
         cpt:'',$                        ;- path of the .cpt file for this object
         off_measure: 0L, $              ;- 0 indexed row number in cpm
         nmeasure: 0L, $                 ;- number of cpm entries
         t_offset: 0L, $                 ;- 0 indexed row number in cpt
         meas_summray: {meas_summary}, $ ;- output from analyze_measurements
         parallax : {parfit}, $          ;- pointer to output from fit_pmpar
         parstatus : -1, $                ;- status of par fitting (1 = success)
         pm : {pmfit}, $                 ;- pointer to output from fit_pm
         pmstatus : -1 $                 ;- status of pm fitting (1 = success)
        }

;- loop over catalogs
for i = 0, ct-1, 1 do begin
   t = mrdfits(ts[i], 1,h,/silent)
   
   ;- only care about objects with many detections
   good = where(t.nmeasure gt 50, gct)
   if gct eq 0 then continue
   t = t[good]

   rms->push, (sqrt(t.ra_err^2 + t.dec_err^2))

   lister = obj_new('looplister', n_elements(t)-1, 30)
   ;- loop over measurements
   for j = 0L, n_elements(t)-1, 1 do begin
      lister->report, j
      m = mrdfits(ms[i],1,h, $
                  range= t[j].off_measure +[0, t[j].nmeasure - 1], $
                  /silent)
      assert, range(m.ave_ref) eq 0
      ;- measure magnitudes, positions
      summary = analyze_measurements(t[j],m)
      myrms->push, (summary.myrms)
      mag->push, (summary.mag)  

      ;- fit parallax, proper motion
      parfit = dvo_fitpar(m, t[j], parstatus, /preclip) ;, binsize = 60)
      pmfit = dvo_fitpar(m, t[j], pmstatus, /preclip, /pm) ;, binsize = 60)
      entry = {entry, cpm : ms[i], cpt : ts[i], $
               off_measure : t[j].off_measure, $
               nmeasure : t[j].nmeasure, $
               t_offset : t[j].obj_id, $
               meas_summray : summary, $
               parallax : parfit, $
               parstatus : parstatus, $
               pm : pmfit, $
               pmstatus : pmstatus}
      parallax->push, (entry)
   endfor ;- done looping over measurements
   obj_destroy,lister
endfor ;- done looping over catalogs

save, mag, rms, myrms, parallax, file='plax_run.sav'

obj_destroy, mag
obj_destroy, rms
obj_destroy, myrms
obj_destroy, parallax

save, magarr, rmsarr, myrmsarr, parallaxarr, file = 'rms.sav'
return
end
