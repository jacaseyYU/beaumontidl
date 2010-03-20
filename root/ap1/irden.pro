PRO irden, bubble

readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a',/silent

sz=r[bubble-1]/60.
l=l[bubble-1]
b=b[bubble-1]

file='/users/cnb/glimpse/glimic/'+strtrim(string(bubble),2)+'.tbl'
openr,1,file
lat=fltarr(200000)
lon=lat
color=lat
in=lat
a=''
i=0
denplot=fltarr(21,21)
while ~ eof(1) do begin
    readf,1,a
    line=strsplit(a,' ',/extract)
    lon[i]=round((line[1]-l)*20.)+10.
    lat[i]=round((line[2]-b)*20.)+10.
    color[i]=line[5]
    in[i]=(((lon[i]-l)^2+(lat[i]-b)^2) le sz^2)
    if color[i] eq 1 then denplot[lon[i],lat[i]]++
    i++
endwhile
close,1

;trim
lat=lat[0:i-1]
lon=lon[0:i-1]
color=color[0:i-1]
in=in[0:i-1]

window,1,xsize=420,ysize=420,title='Bubble '+strtrim(string(bubble),2)

tvscl,rebin(denplot,420,420,/sample)
tvcircle,sz*20.*20.,210,210





END
