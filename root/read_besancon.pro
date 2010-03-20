function read_besancon, file

  compile_opt idl2
  on_error, 2

  if ~file_test(file) then $
     message, 'file not found: '+file

  openr, lun, file, /get_lun
  skip_lun, lun, 90, /lines

  rec = {besancon, dist : 0.0, mv: 0.0, $
         CL: 0, Typ: 0.0, LTef : 0.0, logg : 0.0, age :0, mass: 0.0, $
         ug: 0.0, gr: 0.0, ri: 0.0, iz: 0.0, u: 0.0, $
         mux: 0.0, muy: 0.0, vr: 0.0, $
         uu: 0.0, VV: 0.0, WW: 0.0, FeH: 0.0, $
         l: 0.0, b: 0.0, Av: 0.0, Mbol: 0.0}

  spawn, 'wc -l '+file, nlines
  nlines = long(nlines)
  data = replicate(rec, nlines)
  i = 0L
  line = ''
  fmt =  '((f7.3, f6.2, i3.3, f5.2, f6.3, f6.2, i3.3, f5.2, 5(f7.3), 2(f9.3), 4(f8.2), f6.2, 2(f10.5), 2(f7.3)))'
  while (~eof(lun)) do begin
     readf, lun, line        
     if strmatch(line, '  Dist*') then break
     reads, line, rec, format = fmt
     data[i++] = rec
  endwhile
  free_lun, lun
  data = data[0:i-1]

  return, data
end
