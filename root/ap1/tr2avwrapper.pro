pro tr2avwrapper, infile

infile='/users/cnb/analysis/ircat/36_interior.ircat'
;if n_params() eq 0 then infile=dialog_pickfile(path='/users/cnb/analysis/ircat/')

openr,1,infile
A=''
data=dblarr(50000)
line=dblarr(17)
nrec=0

while ~eof(1) do begin
    readf,1,A
    line[0]=strsplit(A,' ',/extract)
    data[nrec]=tr2av(line[[2,4,6,8,10,12,14]],line[[3,5,7,9,11,13,15]],6.2)
    print,line[[2,4,6,8,10,12,14]]
    print,''
    print,line[[3,5,7,9,11,13,15]]
    print,''
    print,data[nrec]
    print,':::::::'
    stop
    nrec++
endwhile
close,1
data=data[0:nrec-1]
plot,alog10(data),yra=[24,27],/ysty
end
