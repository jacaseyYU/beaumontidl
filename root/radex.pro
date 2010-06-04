;+
; PURPOSE:
;  This procedure writes a file, radex.inp, to be used by a subsquent
;  call to the radex executable. 
;
; INPUTS:
;  molfile: A string naming the molecular data file for radex to use
;  freq: The central frequency (GHz) to list on output.
;  bw: The bandwidth of frequencies (GHz) to list on output. All lines in
;      molfile within freq +/- bw are included on output.
;  tkin: The kinetic temperature of the gas (K)
;  den: The hydrogen density (cm^-3)
;  tback: The background temperature (K)
;  ncol: The column density (cm^-2)
;  linewidth: The line width (km/s)
;
; MODIFICATION HISTORY:
;  May 2010: Written by Chris Beaumont
;-
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

;+
; PURPOSE:
;  This function parses the output created by the radex program, and
;  returns the contents in an IDL structure
;
; OUTPUTS:
;  An array of structures. Each structure contains information on a
;  single transition. The structure contains the following tags:
;   up: A string naming the upper quantum state
;   lo: A string naming the lower quantum state
;   eup: The energy of the upper state above the ground level, in
;        Kelven (that is, E/k)
;   freq: The frquency of the line, in GHz
;   wavel: The wavelength of the line, in microns
;   tex: The exictation temperature of the line (i.e. assumes
;        BB limit. Calculated directly from pop and plo)
;   tau: The opacity of the line
;   t_r: The Rayleigh-Jeans equilvalent radiation temperature (K)
;   pup: The fraction of the molecules in the upper state
;   plo: The fraction of molecules in the lower state
;   flux_kkms: The integrated line flux, in Kelven km/s (RJ limit)
;   flux_ecm2s: The integrated line flux, in erg cm^-2 s^-1 (RJ limit)
;
; KEYWORD PARAMETERS:
;  print: If set, then print the output of the radex program
;
; MODIFICATION HISTORY:
;  May 2010: Written by Chris Beaumont
;-
function radex_read, print = print
  if ~file_test('radex.out') then begin
     message, /con, "Radex.out doesn't exist. Aborting"
     return, !values.f_nan
  endif

  nline = file_lines('radex.out')
  data = strarr(nline)
  openr, lun, 'radex.out', /get_lun
  readf, lun, data
  free_lun, lun
  
  if keyword_set(print) then print, data

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
  

;+
; PURPOSE:
;  This function is a wrapper to the Radex executable program. It runs
;  that program, and returns the results as an IDL structure array.
;  The user must have Radex installed in a place IDL can find. He/she
;  must also change the 'datadir' variable in this file to a location
;  that contains the molecular line data Radex requires.
;
; INPUTS:
;  molecule: A string naming the molecular data file for Radex to use
;  freq: The central frequency (GHz) to return information for
;  bw: The bandwidth (GHz) for output. All lines within freq +/- bw
;      will be included on output
;  tkin: The kinetic temperature (K)
;  den: The density of H2, in cm^-3
;  tback: The background temperature, in K
;  ncol: The column density, in cm^-2
;  linewidth: The linewidth (FWHM), in km/s
;
; KEYWORD PARAMETERS:
;  print: If set, then IDL will print the output of the radex program
;
; OUTPUT:
;  An array of structures, one for each transition of output. The
;  contents of the structures are described in radex_out
;
; MODIFICATION HISTORY:
;  May 2010: Written by Chris Beaumont
;- 
function radex, molecule, freq, bw, tkin, den, tback, ncol, linewidth, print = print

  if n_params() ne 8 then begin
     print, 'calling sequence:'
     print, ' result = radex(molecule, freq, bw, tkin, den, tback, ncol, linewidth)'
     return, -1
  endif

  datadir = '/Users/beaumont/Radex/data/'
  if ~file_test(datadir+molecule) then $
     message, 'cannot find molecule file '+datadir+molecule

  ;- write the input file
  radex_write, molecule, freq, bw, tkin, den, tback, ncol, linewidth


  ;-run the program
  spawn, 'rm radex.out', stdout, stderr
  spawn, 'radex < radex.inp > /dev/null'

  ;-read the results
  return, radex_read(print = keyword_set(print))
end
