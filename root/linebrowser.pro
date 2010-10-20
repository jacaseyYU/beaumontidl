pro linebrowser_event, event
  compile_opt idl2
  widget_control, event.id, get_uvalue = id
  widget_control, event.top, get_uvalue = ptr
  if n_elements(id) eq 0 then return ;- happens for some of the text widgets - don't want any events!

  case id of
     'molecule': begin
        (*ptr).molecule = event.index
        data = linebrowser_parse((*ptr).files[event.index], flo = (*ptr).flo, fhi = (*ptr).fhi)
        (*ptr).data = ptr_new(data)
        (*ptr).transition = 0
        (*ptr).temperature = 0
        widget_control, (*ptr).ts, $
                        set_value = strtrim(data.r_hi, 2) + '-'+$
                        strtrim(data.r_lo, 2)
        widget_control, (*ptr).ts, set_droplist_select = 0
        widget_control, (*ptr).tmp, $
                        set_value = strtrim(fix(data.temp), 2)
        widget_control, (*ptr).tmp, set_droplist_select = 0
     end
     'transition':(*ptr).transition = event.index
     'temperature':(*ptr).temperature = event.index
     'radex': begin
          molecule = (*ptr).names[(*ptr).molecule]+'.dat'
          widget_control, (*ptr).radex_ncol, get_value = ncol
          widget_control, (*ptr).radex_nvol, get_value = nvol
          widget_control, (*ptr).radex_tkin, get_value = tkin
          widget_control, (*ptr).radex_linewidth, get_value = linewidth
          tback = 2.73
          data = *((*ptr).data)
          tran = (*ptr).transition
          freq = data.freq[tran]
          trad = radex(molecule, freq, freq/1d6, float(tkin), float(nvol), tback, float(ncol), float(linewidth))
          lo = min(abs(trad.freq  - freq), hit)
          assert, lo lt 1d-2
          widget_control, (*ptr).radex_trad, set_value = string(trad[hit].flux_kkms, format='(e0.2)')
          return
       end
     else:
  endcase
  linebrowser_update, ptr
end

pro linebrowser_update, ptr
  
  ;-update the labels
  data = *((*ptr).data)
  tran = (*ptr).transition
  temp = (*ptr).temperature
  freq = data.freq[tran]
  tex = data.ex_temp[tran]
  a = data.a[tran]
  b = a * apcon('c')^2 / (2 * apcon('h') * (freq*1d9)^3)
  hit = where(data.c_hi eq data.r_hi[tran] and $
              data.c_lo eq data.r_lo[tran], ct)
  c = ct ne 0 ? data.c[temp, hit[0]] : 0
  nc = a/c
  tex = data.ex_temp[tran]
  fmt = '(e0.2)'
  widget_control, (*ptr).a, set_value=string(a,format = fmt)
  widget_control, (*ptr).b, set_value=string(b, format=fmt)
  widget_control, (*ptr).freq, set_value = string(freq, format = '(e0.6)')
  widget_control, (*ptr).c, set_value = string(c,format = fmt)
  widget_control, (*ptr).t, set_value = string(tex,format=fmt)
  widget_control, (*ptr).n, set_value = string(nc, format=fmt)
  widget_control, (*ptr).radex_trad, set_value=''
end


function linebrowser_parse, file, status = status, fhi = fhi, flo = flo, $
                            verbose = verbose
  status = -1
  testing = 0
  doprint = keyword_set(verbose)

  wsp = ' '+string(9B)

  ;- read in data
  nline = file_lines(file)
  data = strarr(nline)
  openr, lun, file, /get_lun
  readf, lun, data
  free_lun, lun
  
  ;-molecular weight
  if testing then print, 'weight'
  hit = where(strmatch(data, '!MOLECULAR WEIGHT*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'no molecular weight'
     return, -1
  endif

  weight = float(data[hit+1])

  ;-number of levels, energies, and statistical weights
  if testing then print, 'energy levels'
  hit = where(strmatch(data, '*NUMBER OF ENERGY LEVELS*'), ct)
  if ct eq 0 then begin
     if doprint then print, 'No energy levels'
     if ct eq 0 then return, -1
  endif
  nlev = fix(data[hit+1])
  energy = fltarr(nlev)
  g = fltarr(nlev)
  j = strarr(nlev)
  for i = 0, nlev[0]-1, 1 do begin
     line = data[hit+3+i]
     split = strsplit(line, wsp, /extract)
     energy[i] = split[1]
     g[i] = split[2]
     j[i] = split[3]
  endfor
     
  ;- number of transitions
  hit = where(strmatch(data, '*NUMBER OF RADIATIVE TRANSITIONS*'), ct)
  if testing then print, 'radiative transitions'
  if ct eq 0 then begin
     if doprint then print, 'Transition error'
     if ct eq 0 then return, -1
  endif

  ntran = fix(data[hit+1])
  r_hi = strarr(ntran)
  r_lo = strarr(ntran)
  a = fltarr(ntran)
  freq = fltarr(ntran)
  ex_temp = fltarr(ntran)
  for i = 0, ntran[0] - 1, 1 do begin
     line = data[hit+3+i]
     split = strsplit(line, wsp, /extract)
     r_hi[i] = j[split[1]-1]
     r_lo[i] = j[split[2]-1]
     a[i] = split[3]
     freq[i] = split[4]
     ex_temp[i] = split[5]
  endfor
  good = where(freq gt flo and freq lt fhi, ct)
  if ct eq 0 then begin
     if doprint then print, 'no transitions in correct frequency'
     if doprint then print, freq
     return, -1 
  endif else begin
     r_hi = r_hi[good]
     r_lo = r_lo[good]
     a = a[good]
     freq = freq[good]
     ex_temp = ex_temp[good]
  endelse
 
  ;-XXX only deal with one collisional partner for now
  if testing then print, 'collisional transitions'
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
  c_hi = strarr(ntrans)
  c_lo = strarr(ntrans)
  temp = fltarr(ntemp)
  c = fltarr(ntemp, ntrans)
  line = data[hit[0]+3]
  temp = float(strsplit(line, wsp, /extract))
  for i = 0, ntrans - 1, 1 do begin
     line = data[hit[0]+5+i]
     split = strsplit(line, /extract)
     c_hi[i] = j[split[1]-1]
     c_lo[i] = j[split[2]-1]
     c[*, i] = float(split[3:*])
  endfor
 
  status = 0
  ;- create a data structure
  result = {weight : weight, $
            nlev : nlev, $
            energy : energy, $
            g : g, $
            j : j, $
            r_hi : r_hi, $
            r_lo : r_lo, $
            a : a, $
            freq : freq, $
            ex_temp : ex_temp, $
            c_hi : c_hi, $
            c_lo : c_lo, $
            temp : temp, $
            c : c, $
            data : data}
  if doprint then print, 'success'
  if doprint then help, result, /struct
  return, result
end

pro linebrowser, flo = flo, fhi = fhi
  if ~keyword_set(flo) then flo = 325 & if ~keyword_set(fhi) then fhi = 375

  dir=!version.os eq 'darwin' ? '/Users/beaumont/lambda/' : '/home/beaumont/lambda/'
  files = file_search(dir+'*dat', count = ct)
  if ct eq 0 then message, 'Cannot find data files in '+dir

  pos = strpos(files ,'/', /reverse_search)
  names = files
  for i = 0, ct - 1, 1 do names[i] = strtrun(strmid(files[i], pos[i]+1),'.dat')
  good = replicate(0, ct)

  ;- parse files
  for i = 0, ct-1, 1 do begin
     x = linebrowser_parse(files[i], status = s, flo = flo, fhi = fhi)
     good[i] = (s ne -1)        
;     if s eq -1 then print, 'parse error: skipping '+names[i]
  endfor
  keep = where(good, keep_ct)
  if keep_ct eq 0 then begin
     print, 'No transitions in requested frequency range. Aborting'
     return
  endif
  files = files[keep]
  data = linebrowser_parse(files[0], status = s, flo = flo, fhi = fhi, /verbose)

  hit = where(good, ct)
  files = files[hit] & names = names[hit]

  ;- generate the GUI
  tlb = widget_base(column = 2, title='Spectral Line Browser')
  wid1 = 150 & wid2 = 120
  ht = 40
  font = '-adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso8859-1'
;  font = '-adobe-helvetica-medium-r-normal--34-240-100-100-p-176-iso10646-1'
  l = widget_label(tlb, value = 'Molecule  ', xsize = wid1, ysize = ht, /align_r, font=font)
  l = widget_label(tlb, value = 'Transition  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'Temperature (K)  ', xsize =wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'Frequency (GHz)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'A (s^-1)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'B  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'C (cm^3 s^-1)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'Tex (K)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'n_cr (cm^-3)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'Min freq (GHz)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'Max freq (GHz)  ', xsize = wid1, ysize = ht, /align_r, font = font)
  l = widget_label(tlb, value = 'RADEX Simulation  ', xsize = wid1, ysize = ht, /align_r, font = font)
  ht2 = ht * .8
  l = widget_label(tlb, value = 'Column Density (cm^-2)  ', xsize = wid1, ysize = ht2, /align_r, font = font)
  l = widget_label(tlb, value = 'Density (cm^-3)  ', xsize = wid1, ysize= ht2, /align_r, font = font)
  l = widget_label(tlb, value = 'Tkin (K)  ', xsize = wid1, ysize = ht2, /align_r, font = font)
  l = widget_label(tlb, value = 'Linewidth (km s^-1)  ', xsize = wid1, ysize = ht2, /align_r, font = font)
  l = widget_label(tlb, value = 'Integrated Flux (K km/s)', xsize = wid1, ysize = ht2, /align_r, font = font)
  l = widget_label(tlb, value='', xsize = wid1, ysize = ht, /align_r, font = font)

  
  ms = widget_droplist(tlb, value = names, uvalue = 'molecule', xsize = wid2, ysize = ht, font = font)
  ts = widget_droplist(tlb, value = strtrim(data.r_hi,2)+'-'+ strtrim(data.r_lo,2), $
                       uvalue = 'transition', xsize = wid2, ysize = ht, font= font)
  tmp = widget_droplist(tlb, value = strtrim(fix(data.temp), 2), uvalue='temperature', $
                        xsize = wid2, ysize =ht, font= font)
  f = widget_label(tlb, value='', uvalue = 'freq', xsize = wid2, ysize = ht, /align_l, font= font)
  a = widget_label(tlb, value='', uvalue = 'a', xsize = wid2, ysize = ht, /align_l, font = font)
  b = widget_label(tlb, value='', uvalue = 'b', xsize = wid2, ysize = ht, /align_l, font = font)
  c = widget_label(tlb, value='', uvalue = 'c', xsize = wid2, ysize = ht, /align_l, font=font)
  t = widget_label(tlb, value='', uvalue='tex', xsize =wid2, ysize = ht, /align_l, font = font)
  n = widget_label(tlb, value='', uvalue='ncr', xsize = wid2, ysize = ht, /align_l, font = font)
  l = widget_label(tlb, value=strtrim(flo,2), uvalue='flo', xsize = wid2, ysize = ht, /align_l, font = font)
  l = widget_label(tlb, value=strtrim(fhi,2), uvalue='fhi', xsize = wid2, ysize = ht, /align_l, font = font)
  l = widget_label(tlb, value = ' ', xsize = wid1, ysize = ht, /align_r, font = font)
  radex_ncol = widget_text(tlb, value = '1e15', xsize = 10, ysize = 1, /align_l, font = font, /edit, /all)
  radex_nvol = widget_text(tlb, value = '1e2 ', xsize = 10, ysize= 1, /align_l, font = font, /edit, /all)
  radex_tkin = widget_text(tlb, value = '20', xsize = 10, ysize = 1, /align_l, font = font, /edit, /all)
  radex_linewidth = widget_text(tlb, value = '1', xsize = 10, ysize = 1, /align_l, font = font, /edit, /all)
  radex_trad = widget_label(tlb, value = '', xsize = wid2, ysize = ht, /align_l, font = font)
  radex = widget_button(tlb, uvalue='radex', value='Run RADEX', xsize = wid2, ysize = ht)

  info = {files : files, names : names, data : ptr_new(data), $
         molecule : 0, transition: 0, temperature : 0, $
         freq : f, a : a, b : b, c : c, t : t, n : n, ts : ts, tmp : tmp, flo : flo, fhi:fhi, $
         ms : ms, radex_ncol : radex_ncol, radex_nvol : radex_nvol, radex_tkin : radex_tkin, $
         radex_linewidth : radex_linewidth, radex_trad : radex_trad}
  ptr = ptr_new(info,/no_copy)
  widget_control, tlb, set_uvalue = ptr
  linebrowser_update, ptr
  widget_control, tlb, /realize
  xmanager, 'linebrowser', tlb
  ptr_free, ptr

  
end

