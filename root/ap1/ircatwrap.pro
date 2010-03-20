pro ircatwrap

;-create ir catalogs of every region in /users/cnb/analysis/reg that
;doesn't already exist in /users/cnb/analysis/ircat/


filelist=file_search('/users/cnb/analysis/reg/*.reg',count=ct)
for i=0,ct-1,1 do begin
    print,filelist[i]
;test for pre-existing file
    temp=strsplit(filelist[i],'/',/extract)
    temp=temp[n_elements(temp)-1]
    temp=strsplit(temp,'.',/extract)
    temp=temp[0]
    if file_test('/users/cnb/analysis/ircat/'+temp+'.ircat') then continue
    print,'running ircat'
    ircat,filelist[i]
endfor

end
