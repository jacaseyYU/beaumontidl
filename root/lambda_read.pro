function lambda_read, file, verbose = verbose

  wsp = ' '+string(9B)
  doPrint = keyword_set(verbose)

  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, '  result = lambda_read(file)'
  endif

  if ~file_test(file) then $
     message, 'File not found'

  ;- read data into string array
  nline = file_lines(file)
  data = strarr(nline)
  openr, lun, file, /get_lun
  readf, lun, data
  free_lun, lun

  ;- molecule
  hit = where(strmatch(data, '!MOLECULE*'), ct)
  if ct eq 0 then begin
     if doPrint then print, 'No Molecule'
     return, -1
  endif
  molecule = data[hit[0]+1]

  ;-molecular weight
  if doPrint then print, 'Parse weight'
  hit = where(strmatch(data, '!MOLECULAR WEIGHT*'), ct)
  if ct eq 0 then begin
     if doPrint then print, 'No molecular weight'
     return, -1
  endif
  weight = float(data[hit[0]+1])

  ;-number of levels, energies, and statistical weights
  if doPrint then print, 'energy levels'
  hit = where(strmatch(data, '*NUMBER OF ENERGY LEVELS*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'No energy levels'
     if ct eq 0 then return, -1
  endif
  nlev = fix(data[hit[0]+1])
  energy = dblarr(nlev)
  g = fltarr(nlev)
  j = strarr(nlev)
  level_label= data[hit[0]+2]
  
  for i = 0, nlev[0]-1, 1 do begin
     line = data[hit+3+i]
     split = strsplit(line, wsp, /extract)
     energy[i] = split[1]
     g[i] = split[2]
     j[i] = split[3]
  endfor
     
  ;- number of transitions
  hit = where(strmatch(data, '*NUMBER OF RADIATIVE TRANSITIONS*'), ct)
  if doPrint then print, 'radiative transitions'
  if ct eq 0 then begin
     if doprint then print, 'Transition error'
     if ct eq 0 then return, -1
  endif

  ntran = fix(data[hit+1])
  r_hi = intarr(ntran)
  r_lo = intarr(ntran)
  a = fltarr(ntran)
  freq = dblarr(ntran)
  ex_temp = fltarr(ntran)
  for i = 0, ntran[0] - 1, 1 do begin
     line = data[hit+3+i]
     split = strsplit(line, wsp, /extract)
     r_hi[i] = split[1]
     r_lo[i] = split[2]
     a[i] = split[3]
     freq[i] = split[4]
     ex_temp[i] = split[5]
  endfor

  ;-XXX only deal with one collisional partner for now
  hit = where(strmatch(data, '!NUMBER OF COLL PARTNERS*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'Number of collision partners'
     return, -1
  endif
  if float(data[hit[0]+1]) gt 1 then $
     message, /con, 'WARNING: multiple collision partners present. '+$
              'Only parsing the first partner'

  hit = where(strmatch(data, '!COLLISIONS BETWEEN*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'Collision partner'
     return, -1
  endif
  partner=data[hit[0]+1]
 
  if doprint then print, 'collisional transitions'
  hit = where(strmatch(data, '!NUMBER OF COLL TRANS*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'Coll trans'
     return, -1
  endif
  ntrans = fix(data[hit[0]+1])


  hit = where(strmatch(data, '!NUMBER OF COLL TEMPS*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'Coll temps'
     return, -1
  endif
  ntemp = fix(data[hit[0]+1])
  c_hi = intarr(ntrans)
  c_lo = intarr(ntrans)
  temp = fltarr(ntemp)
  c = fltarr(ntemp, ntrans)
  line = data[hit[0]+3]
  temp = float(strsplit(line, wsp, /extract))
  for i = 0, ntrans - 1, 1 do begin
     line = data[hit[0]+5+i]
     split = strsplit(line, /extract)
     c_hi[i] = split[1]
     c_lo[i] = split[2]
     c[*, i] = float(split[3:*])
  endfor
 
  status = 0
  ;- create a data structure
  result = {molecule:molecule, $
            weight : weight, $
            nlev : nlev, $
            level_label:level_label, $
            energy : energy, $
            g : g, $
            j : j, $
            r_hi : r_hi, $
            r_lo : r_lo, $
            a : a, $
            freq : freq, $
            ex_temp : ex_temp, $
            partner:partner, $
            c_hi : c_hi, $
            c_lo : c_lo, $
            temp : temp, $
            c : c, $
            data : data}
  if doprint then print, 'success'
  if doprint then help, result, /struct
  return, result
end

pro test
  x = lambda_read('~/lambda/a-ch3oh.dat', /verbose)
;  help, x, /struct
  print, x.c_hi[0], x.c_lo[0]
  print, x.temp
end
