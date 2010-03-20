pro deredden, ircatfile, mean=m
;- use the nicer procedure to deredden stars in an ircat file

;- check parameters

;on_error, 2
if n_params() eq 0 then infile=dialog_pickfile(path='/users/cnb/analysis/ircat/',title='Pick an IRCAT file') else $
  infile='/users/cnb/analysis/ircat/'+ircatfile

;!!!temporary!
;ircatfile='21_interior.ircat'
test=file_test(infile)
if ~test then message, 'Error -- File not found'

;- read the table
openr, 1, infile
A=''
fmt='(2D12.6,14D8.3,I2)'
data=dblarr(17, 50000)
i=0

while ~eof(1) do begin
    readf,1,A
    line=strsplit(A,' ',/extract)
    data[*,i]=line
    i++
endwhile

data=data[*,0:i-1]
close,1

;- feed into nicer
result=nicer(data[2,*],data[3,*],data[4,*],data[5,*],data[6,*],data[7,*])

;-correct all photometry points for which nicer should perform well
;-A values from Indebetouw et al 2005 ApJ 619:931
;-akv from Rieke and Lebofsky 1985 ApJ 288:618

akv=0.112
aj=2.50*akv
ah=1.55*akv
ak=1.00*akv
a1=0.56*akv
a2=0.43*akv
a3=0.43*akv
a4=0.43*akv
as=[aj,ah,ak,a1,a2,a3,a4]

;-only consider points with at least 2 good 2mass photometry points
cut1=(((data[2,*] le 99) + (data[4,*] le 99) + (data[6,*] le 99)) ge 2)
for i=2,14,2 do begin
    good=where(cut1 and (data[i,*] le 99), ct)
    if ct eq 0 then continue
    data[i,good]-=(as[(i-2)/2]*result[0,good])
    data[i+1,good]=result[1,good]*as[(i-2)/2]
endfor

;- make a histogram
window,1,retain=2,xsize=600,ysize=400
good=where(cut1, ct)
if ct ge 0 then begin
    binned=histogram(result[0,good],locations=loc,binsize=1)
    plot,loc,binned,psym=10,xtitle='Av',ytitle='N', yrange=[0,max(binned)+1],xrange=[floor(min(loc))-1,ceil(max(loc))+1],/ysty,/xsty
    print,total(binned*loc)/total(binned),format="('Mean: ',f5.1)"
    print,loc[(where(binned eq max(binned)))[0]], format="('Mode: ',f5.1)"
    temp=0;
    for i=0,n_elements(binned)-1, 1 do begin
        temp+=binned[i]
        if temp ge total(binned)/2 then break
    endfor
    print,loc[i],format="('Median: ',f5.1)"
    if arg_present(m) then begin
        m=[total(binned*loc)/total(binned),total(binned)]
    endif
endif

;- write the dereddened table to file
outfile=strsplit(infile,'/',/extract)
outfile=outfile[n_elements(outfile)-1]
outfile=strsplit(outfile,'.',/extract)
outfile='/users/cnb/analysis/dered/'+outfile[0]+'.dered'

nrec=n_elements(data[0,*])
out=dblarr(19,nrec)
out[0:16,*]=data
out[17,*]=99
out[18,*]=99
out[17,good]=result[0,good]
out[18,good]=result[1,good]

fmt='(2D12.6,14D8.3,I2,2F6.1)'
openw,1,outfile
printf,1,out,format=fmt

close,1
end

