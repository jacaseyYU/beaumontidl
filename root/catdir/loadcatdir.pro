pro loadcatdir, dir, meas, avg, sec, miss, image
  compile_opt idl2
  on_error, 2

  ;-check for inputs and catdir integrity
  if n_params() ne 6 then begin
     print, 'loadCatdir calling sequence: '
     print, 'loadCatdir, dir, meas, avg, sec, miss, image'
     return
  endif

  if ~file_test(dir) then message, 'No catdir found at '+dir

  if ~file_test(dir + '/Images.dat') then  message, 'Images.dat not found in '+dir
  image = mrdfits(dir+ '/Images.dat', 1, /silent)
  
  mfile = file_search(dir+'/*/*.cpm', count = mct)
  tfile = file_search(dir+'/*/*.cpt', count = act)
  sfile = file_search(dir+'/*/*.cps', count = sct)
  nfile = file_search(dir+'/*/*.cpn', count = nct)
  
  if mct eq 0 then message, 'Cannot find data tables in '+dir

  if mct ne act || mct ne sct || mct ne nct then $
     message,'There is not a 1-to-1 correspondance between the different table types in '+dir

  ;-initialize objects
  ms = obj_new('stack')
  ts = obj_new('stack')
  ss = obj_new('stack')
  ns = obj_new('stack')

  ;-set up error handling
  catch, theError
  if (theError ne 0) then begin
     catch, /cancel
     print, 'Exception raised during table loading. Aborting'
     obj_destroy, ms
     obj_destroy, ts
     obj_destroy, ss
     obj_destroy, ns
     return
  endif

  
  ;-read in files to stacks
  for i = 0, mct - 1, 1 do begin
     m = mrdfits(mfile[i],1,/silent)
     m.ave_ref += ts->getSize() 
     n = mrdfits(nfile[i],1,/silent)
     s = mrdfits(sfile[i],1,/silent)
     t = mrdfits(tfile[i],1,/silent)
     t.off_measure += ms->getSize()
     junk = ms->push(m)
     junk = ns->push(n)
     junk = ss->push(s)
     junk = ts->push(t)
  endfor

  ;- populate output variables, destroy objects
  meas = ms->toArray()
  avg = ts->toArray()
  sec = ss->toArray()
  miss = ns->toArray()
  
  obj_destroy, ms
  obj_destroy, ts
  obj_destroy, ss
  obj_destroy, ns
  
end
  
