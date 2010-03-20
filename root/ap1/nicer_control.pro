pro nicer_control

;evaluate the covariance matrix of intrinsic MS IR colors
;using a 2MASS Control field assumed to have little extinction

;See Lombardi and Alves 2001. Uses the same test field


;- read the control catalog
infile='/users/cnb/analysis/2mass_control_field.txt'

openr,1,infile
A=''
skip_lun,1,19,/lines

data=fltarr(8,16078)
i=0;
while ~eof(1) do begin
	readf,1,A
	row=strsplit(A,' ',/extract)
    if (row[0] eq 'null' || row[1] eq 'null' || row[3] eq 'null' || row[4] eq 'null' $
        || row[6] eq 'null' || row[7] eq 'null' || row[9] eq 'null' || row[10] eq 'null') then continue
        data[*,i]=float(row[[0,1,3,4,6,7,9,10]])
        i++
    endwhile
close,1
data=data[*,0:i-1]
plot,data[4,*]-data[6,*],data[2,*]-data[4,*],xra=[-1,2.5], yra=[-.5,3],/xsty,/ysty,psym=3

c1=data[2,*]-data[4,*]
c2=data[4,*]-data[6,*]
cov11=variance(c1)
cov12=mean((c1-mean(c1))*(c2-mean(c2)))
cov22=variance(c2)

print, 'For color1=J-H, color2=H-K'

cov=[[cov11,cov12],[cov12,cov22]]
print, 'Covariance Matrix: '
print,cov

print, 'Avg J-H', mean(data[2,*] - data[4,*])
print, 'Avg H-K', mean(data[4,*] - data[6,*])

end
