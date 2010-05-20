pro radex_write, molfile, freq, bw, tkin, den, tback, ncol, linewidth
  openw,  lun, 'radex.inp', /get_lun
  printf, lun, molfile
  printf, lun, 'radex.out'
  printf, lun, freq - bw, freq + bw, format='(f0.4, " ", f0.4)'
  printf, lun, tkin, format='(f0.1)'
  printf, lun, '1' ;- only H2 collisions in most files
  printf, lun, 'H2' ;- only H2 collisions in most files
  printf, lun, den, format='(f0)'
  printf, lun, tback, format='(f0.2)'
  printf, lun, ncol, format='(e0.2)'
  printf, lun, linewidth, format='(f0.2)'
  printf, lun, '0'
  free_lun, lun
end


function radex_read
  nline = file_lines('radex.out')
  data = strarr(nline)
  openr, lun, 'radex.out', /get_lun
  readf, lun, data
  free_lun, lun
  
  ;- assumption -there should only be one transition of output,
  ;- on the last line
  stars = strmatch(data, '\**')
  nrec = nline - total(stars) - 3
  
  entry = {up:'', lo:'', eup:0., freq:0., wavel:0., tex:0., tau:0., tr:0., pup:0., plo:0., flux_kkms:0., flux_ecm2s:0.}
  result = replicate(entry, nrec)
  for i = 0, nrec - 1, 1 do begin
     line = data[total(stars)+3+i]
     split = strsplit(line, ' ', /extract)
     nelem = n_elements(split)
     assert, nelem eq 13
     result[i].up = split[0]
     for j = 1, 11, 1 do result[i].(j) = split[2+j-1]
  endfor
  return, result
end
  

function radex, molecule, freq, bw, tkin, den, tback, ncol, linewidth

  if n_params() ne 8 then begin
     print, 'calling sequence:'
     print, ' Trad = radex(molecule, freq, bw, tkin, den, tback, ncol, linewidth'
     return, -1
  endif

  datadir = '/Users/beaumont/Radex/data/'
  if ~file_test(datadir+molecule) then $
     message, 'cannot find molecule file '+datadir+molecule

  ;- write the input file
  radex_write, molecule, freq, bw, tkin, den, tback, ncol, linewidth


  ;-run the program
  spawn, 'radex < radex.inp > /dev/null'

  ;-read the results
  return, radex_read()
end
