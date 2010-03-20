pro lspm_read

  file = '~/parallax_papers/LSPM.tsv'
  if ~file_test(file) then begin
     print, file+' not found.'
     return
  endif
  
  line = ''
  entry = {lspm, lspm_id: '', nltt_id : '', usno_id : '', $
          ra : 0D, dec : 0D, pm : 0D, pmRA : 0D, pmDec : 0D, $
          flag : '', v : 0D, vj : 0D}
  data = replicate(entry, 62000)

  openr, lun, file, /get_lun
  skip_lun, lun, 32, /lines
  
  i = 0L
  while ~eof(lun) do begin
     readf, lun, line
     split = strsplit(line, '|', /extract)
    
     if n_elements(split) eq 9 then split = [split, '99.99', '99.99']
     if n_elements(split) eq 10 then split = [split, '99.99']
     if stregex(split[9], '^[ ]+$') eq 0 then split[9] = '99.99'
     if stregex(split[10], '^[ ]+$') eq 0 then split[10] = '99.99'
     data[i++] = {lspm, lspm_id : split[0], nltt_id : split[1], usno_id : split[2], $
                  ra : split[3], dec : split[4], pm : split[5], pmRA : split[6], $
                  pmDec : split[7], flag : split[8], v : split[9], vj : split[10]}
;     stop
  endwhile
  
  close, lun
  free_lun, lun

  data = data[0:i-1]

  save, data, file='~/pro/lspm.sav'
end
