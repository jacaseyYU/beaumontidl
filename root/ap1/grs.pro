PRO grs, bubble,chanmin,chanmax

data=file_search('grs/'+bubble+'.fits')
if data eq '' then begin
    print,'BAD BUBBLE'
    STOP
endif
cube=mrdfits(data[0],0,hdr,/silent,/fscale)


;remove nan regions
beam=cube[90,90,*]
bad=where(finite(beam) eq 0, count)
if count ne 0 then begin
    cube=cube[*,*,0:min(bad)-1]
    sxaddpar,hdr,'NAXIS3',min(bad)
endif

ncols=n_elements(cube[*,0,0])
nrows=n_elements(cube[0,*,0])
nchan=n_elements(cube[0,0,*])
if keyword_set(chanmin) eq 0 then chanmin=0
if keyword_set(chanmax) eq 0 then chanmax=nchan-1
print,'summing from'+string(chanmin)+' to '+string(chanmax)

mask=fltarr(ncols,nrows)
mask[*,*]=finite(cube[*,*,0]);which regions of a slice are good
if min(mask) eq 0 then cube[where(finite(cube) eq 0)]=1.;just for arithmetic

;create velocity label cube
crpix3=sxpar(hdr,'CRPIX3')
crval3=sxpar(hdr,'CRVAL3')
cdelt3=sxpar(hdr,'CDELT3')
vchan=fltarr(ncols,nrows,nchan)

for i=0, nchan-1, 1 do begin
    vchan[*,*,i]=((i+1-crpix3)*cdelt3+crval3)/1000.
endfor
vmax=((chanmax+1-crpix3)*cdelt3+crval3)/1000.
vmin=((chanmin+1-crpix3)*cdelt3+crval3)/1000.


;create moment maps
sm=min(cube)
mom0=total(cube[*,*,chanmin:chanmax],3)
mom1=total((cube[*,*,chanmin:chanmax]-sm)*vchan[*,*,chanmin:chanmax],3)/(mom0-sm*(chanmax-chanmin+1));mom1 gt 0
;mask out bad regions
mom0*=mask
mom1*=mask
mom0+=(1-mask)*median(mom0)
mom1+=(1-mask)*median(mom1)

;sigma clip
bad=where(abs(mom0-median(mom0))/stdev(mom0) gt 9,count)
if count ne 0 then begin
    print,'flagging '+strtrim(string(count),2)+' bad pixels'
    sxaddhist,'clipped '+strtrim(string(count),2)+' pixels.',hdr
    mom0[bad]=median(mom0)
    mom1[bad]=median(mom1)
endif

;create new headers for mom0 and mom1

sxaddpar,hdr,'NAXIS',2
sxaddpar,hdr,'EQUINOX',2000.
sxdelpar,hdr,'NAXIS3'
sxdelpar,hdr,'CTYPE3'
sxdelpar,hdr,'CRVAL3'
sxdelpar,hdr,'CDELT3'
sxdelpar,hdr,'CRPIX3'
sxdelpar,hdr,'CROTA3'
sxaddpar,hdr,'OBJECT',bubble+' from '+strtrim(string(vmin),2)+' to '+strtrim(string(vmax),2)+' km/s'
sxaddhist,'Moments summed from channel '+strtrim(string(chanmin),2)+' to channel '+strtrim(string(chanmax),2),hdr

hdr0=hdr
hdr1=hdr

sxaddpar,hdr1,'BUNIT','VELOCITY','Kilometers per Second'
sxaddpar,hdr1,'DATAMIN',min(mom1)
sxaddpar,hdr1,'DATAMAX',max(mom1)
sxaddpar,hdr0,'DATAMIN',min(mom0)
sxaddpar,hdr0,'DATAMAX',max(mom0)



;write fits
mwrfits,mom0,'grs/'+bubble+'_mom0.fits',hdr0,/create
mwrfits,mom1,'grs/'+bubble+'_mom1.fits',hdr1,/create

;create color JPEGS

mom0-=min(mom0)
mom0/=max(mom0)


mid=median(mom1)
st=stdev(mom1)
mom1-=(mid-5*st)
mom1/=(10*st)

lo=where(mom1 lt 0, count)
if count ne 0 then mom1[lo]=0
hi=where(mom1 gt 1, count)
if count ne 0 then mom1[hi]=1

;if min(mom1) lt 0 then begin
;    bad=where(mom1 lt 0,count)
;    print,'mom1 lt vmin '+strtrim(string(count),2)+' times'
;    mom0[bad]=0.
;endif

;if max(mom1) gt 1 then begin
;    bad=where(mom1 gt 1, count)
;    print,'mom1 gt vmax '+strtrim(string(count),2)+' times'
;    mom0[bad]=0.
;endif

hue=240.0*mom1
value=mom0

color_convert,hue,fltarr(ncols,nrows)+1.0,value,r,g,b,/hsv_rgb

image=fltarr(ncols,nrows,3)
image[*,*,0]=r
image[*,*,1]=g
image[*,*,2]=b


write_jpeg,'grs/'+bubble+'_mom1.jpg',image,true=3,quality=100
write_jpeg,'grs/'+bubble+'_mom0.jpg',value*255.,quality=100

END
