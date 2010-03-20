pro readCatToVar

;-read all of the GLIMIC catalogs into structures, save them as IDL
;binary files for faster access later.


files = file_search('/users/cnb/glimpse/glimic/*tbl', count=ct)

for i=0, ct-1, 1 do begin
    print, i+1, ct, format="('Reading catalog ', i2.2, ' of ', i2.2)"
    outfile=strmid(files[i],35,2)+'.sav'
    glimic = readglimic(files[i])
    save, file=outfile, glimic
endfor
end
