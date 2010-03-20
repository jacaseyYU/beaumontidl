PRO irplot, bubble

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
while ~ eof(1) do begin
    readf,1,a
    line=strsplit(a,' ',/extract)
    lon[i]=line[1]
    lat[i]=line[2]
    color[i]=line[5]
    in[i]=(((lon[i]-l)^2+(lat[i]-b)^2) le sz^2)
    i++
endwhile
close,1

;trim
lat=lat[0:i-1]
lon=lon[0:i-1]
color=color[0:i-1]
in=in[0:i-1]

xs=where(color eq 1, c1)
nxs=where(color eq 0, c2)


window,1,xsize=800,ysize=800,title='Bubble '+strtrim(string(bubble),2)

scale=3.
if c2 ne 0 then plot,lon[nxs],lat[nxs],psym=3,xrange=[l-scale*sz,l+scale*sz],$
yrange=[b-scale*sz,b+scale*sz],/xstyle,/ystyle

if c1 ne 0 then oplot,lon[xs],lat[xs],psym=6,symsize=.3,color='0000ff'xl

tvcircle,sz,l,b,/data

temp=where(color and in, ct)
temp=where(~color and in,ct2)
ct=double(ct)
ct2=double(ct2)
frac=ct/(ct+ct2)
err=sqrt(ct*ct2/(ct+ct2)^3.)
s1=frac
s2=err
frac=strtrim(string(frac),2)
frac=strmid(frac,0,5)
err=strtrim(string(err),2)
err=strmid(err,0,5)
print,'IR excess source fraction in bubble: '+frac+' +/- '+err

temp=where(color and (~in),ct)
temp=where(~color and (~in), ct2)
ct=double(ct)
ct2=double(ct2)
frac=ct/(ct+ct2)
err=sqrt(ct*ct2/(ct+ct2)^3.)
s3=frac
frac=strtrim(string(frac),2)
frac=strmid(frac,0,5)
err=strtrim(string(err),2)
err=strmid(err,0,5)
print,'IR excess source fraction out of bubble: '+frac+' +/- '+err

sigma=(s1-s3)/s2
sigma=strtrim(string(sigma),2)
sigma=strmid(sigma,0,4)
print,'Significance of overdensity: '+sigma+' sigma'

END
