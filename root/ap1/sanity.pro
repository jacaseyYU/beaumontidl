pro sanity
;check 108 and 109 for consistency

f1='/users/cnb/glimpse/glimic/108.tbl'
f2='/users/cnb/glimpse/glimic/109.tbl'

readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a',/silent

;N108 parameters
sz=r[107]/60.
l=l[107]
b=b[107]


openr,1,f1
openr,2,f2

a=''
i=0

name=strarr(30000)
lat=fltarr(30000)
lon=lat

;read in N108 data
while ~ eof(1) do begin
    readf,1,a
    line=strsplit(a,' ',/extract)
    lon[i]=line[1]
    lat[i]=line[2]
    name[i]=line[0]
    i++
endwhile
close,1

;read in N109 data
a=''
j=0
k=0
while ~eof(2) do begin
    readf,2,a
    line=strsplit(a,' ',/extract)
    if ((line[1]-l)^2.+(line[2]-b)^2.) lt .5^2 then begin
       hit=where(name eq line[0],ct)
       if ct ne 1 then print,' AHH!',ct
       j+=1
       k+=ct
    endif

    i++
endwhile
print,j,k
close,2


;repeat the other way
readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a',/silent


;N109 parameters
sz=r[108]/60.
l=l[108]
b=b[108]


openr,1,f2
openr,2,f1

a=''
i=0

name=strarr(30000)
lat=fltarr(30000)
lon=lat

;read in N109 data
while ~ eof(1) do begin
    readf,1,a
    line=strsplit(a,' ',/extract)
    lon[i]=line[1]
    lat[i]=line[2]
    name[i]=line[0]
    i++
endwhile
close,1

;read in N108 data
a=''
j=0
k=0
while ~eof(2) do begin
    readf,2,a
    line=strsplit(a,' ',/extract)
    if ((line[1]-l)^2.+(line[2]-b)^2.) lt .5^2 then begin
       hit=where(name eq line[0],ct)
       if ct ne 1 then print,' AHH!',ct
       j+=1
       k+=ct
    endif

    i++
endwhile
print,j,k
close,2
end