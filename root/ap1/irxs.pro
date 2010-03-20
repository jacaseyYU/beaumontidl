pro irxs, bubble

;*********************
;DESCRIPTION:irxs searches through GLMIC catalogs
;to find sources within a .5 degree radius circle
;centered on a bubble. It creates a new, much smaller
;table of those sources nearby the bubble with
;IRAC photometry
;
;INPUTS: bubble- the number of a bubble in the
;Churchwell N1 catalog
;
;OUTPUTS: A table of sources nearby bubble
;
;***********************


;get bubble info
readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a'

l=l[bubble-1]
b=b[bubble-1]


;select input catalogs
lon=strtrim(string(floor(l)),2)
lat=strtrim(string(floor(b)),2)

if (l mod 1) le 0.5 then l2=strtrim(string(lon-1),2) else l2=strtrim(string(lon+1),2)
infile1='/users/cnb/glimpse/glimic/GLMIC_l0'+lon+'.tbl'
infile2='/users/cnb/glimpse/glimic/GLMIC_l0'+l2+'.tbl'
outfile='/users/cnb/glimpse/glimic/'+strtrim(string(bubble),2)+'.tbl'
print,'analyzing bubble N'+strtrim(string(bubble),2)
print,'looking at catalogs '+lon+' and '+l2

; I/O
OPENW, 1, outfile
infile=infile1
print,'reading file 1'
for i=0, 1, 1 do begin
    openr,2,infile
    A = ''
    skip_lun,2,13,/lines

    WHILE ~ EOF(2) DO BEGIN
       READF, 2, A
       row=strsplit(A,' ',/extract)
       dist=(row[4]-l)^2+(row[5]-b)^2
        ;is the object in the 1 degree window?
       if dist lt 0.25 then begin
            ;check for irac photometry
            if ((row[21] eq 99.999) or (row[25] eq 99.999)) then continue
            if ((row[19] eq 99.999) or (row[23] eq 99.999)) then continue
            ;temp=float(row[21])-float(row[25])
            ;flag=((temp gt 0.5) and (float(row[25]) lt (14-temp)))
            printf,1,row[[1,4,5,19,21,23,25]],format='(a26,2(f11.6),4(f7.3))'
        endif
    ENDWHILE
    CLOSE,2

    infile=infile2
    print,'reading file 2'
endfor

; Close the output file:
CLOSE, 1

end

