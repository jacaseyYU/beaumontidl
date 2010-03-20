;+
; NAME:
;  trends
;
; DESCRIPTION:
;  This program untars the catdir iteration tarballs, runs getScatter
;  on them, and stops to allow me to examine how relastro is
;  proceeding
;
; 
;-

pro trends

files = file_search('*.tar')

for i = 0, n_elements(files) -1 , 1 do begin
    print, 'reading iterations ', i + 1, ' of ', n_elements(files)
    spawn, 'tar -xf '+files[i]
    success = execute('dat'+strtrim(string(i),2)+' = fetchScatter("catdir.107")')
    if (success eq 0) then stop
endfor

save, dat0, dat1, dat2, dat3, dat4, dat5, dat6, dat7, dat8, dat9, dat10, dat11, $
  file = 'dat.sav'
return

end
