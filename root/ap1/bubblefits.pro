pro bubblefits,bubble
;**************************
;for bubble, create a cropped fits imagage from the IRAC band 3
;mosaic. If necessary, download the mosaic. Create a new header, and
;save the file
;
;UPDATE: June 4: Realizing that 8 micron data (band 4) is more
;extended and brighter
;download THIS data for comparison instead of 5.8 micron.
;**************************

;!!!!!!!!!!!!!!!!!!!!!!!!!!!
;bubble=999
;;temp workaround-delete this!!!!!!
;xcen=54.0962
;ycen=.266349
;sz=5/60.
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;restore this!!!
;determine image properties
restore,file='fields.sav'
xcen=fields[bubble,1]
ycen=fields[bubble,2]
sz=1.5*sqrt(fields[bubble,3]^2+fields[bubble,4]^2)/(2.*60.)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!

band='I4'

;mosaic index info
lcen=9+indgen(30)*3

;find best fit mosaic
in=where(abs(lcen-xcen)  eq  min(abs(lcen-xcen)))

;make sure the bubble is inside
if abs(lcen[in]-xcen) ge 1.55 then begin
    print, 'error: bad bubble location'
    goto, theend
endif

;parse together filename
num=strtrim(string(lcen[in]),2)
num=num[0]
if lcen[in] lt 100 then num='0'+num
if lcen[in] lt 10 then num='0'+num

dir='GLON_53-65/'
if lcen[in] lt 53 then dir='GLON_30-53/'
if lcen[in] lt 30 then dir='GLON_10-30/'

url='http://data.spitzer.caltech.edu/popular/glimpse/20070416_enhanced_v2/3.1x2.4_mosaics/'
file='GLM_'+num+'00+0000_mosaic_'+band

;!!!!!!!!!!!!!!!!!!!!!!
;SPITZER 03900 I4 file is corrupt at the moment. skip this
;if num eq '039' and band eq 'I4' then begin
;print,'WARNING: SKIPPING DATA IN CORRUPT 39 I4 FILE'
;goto,theend
;endif
;!!!!!!!!!!!!!!!!!!!!!!

;do we already have the fits file?
test=file_test('/users/cnb/glimpse/fits/mosaic/'+file+'.fits')

if test then begin
    print,'mosaic already downloaded. continuing...'
endif else begin
    print,'downloading mosaic from web...'
    spawn, 'curl '+url+dir+file+'.hdr > /users/cnb/glimpse/fits/mosaic/'+file+'.hdr'
    spawn, 'curl '+url+dir+file+'.fits > /users/cnb/glimpse/fits/mosaic/'+file+'.fits'
endelse

;read in file
im=mrdfits('/users/cnb/glimpse/fits/mosaic/'+file+'.fits',0)
sxhread,'/users/cnb/glimpse/fits/mosaic/'+file+'.hdr',h
nx=n_elements(im[*,0])
ny=n_elements(im[0,*])

;extract bubble region

crval1=sxpar(h,'crval1')
crval2=sxpar(h,'crval2')
crpix1=sxpar(h,'crpix1')
crpix2=sxpar(h,'crpix2')
cd1_1=sxpar(h,'cd1_1')
cd2_2=sxpar(h,'cd2_2')

xpixcen=round((xcen-crval1)/cd1_1+crpix1)
ypixcen=round((ycen-crval2)/cd2_2+crpix2)
sz=round(sz/abs(cd1_1))            ;assuming square pixels here

top=min([ny-1,ypixcen+sz])
bot=max([0,ypixcen-sz])
left=max([0,xpixcen-sz])
right=min([nx-1,xpixcen+sz])

crop=fltarr(2*sz+1,2*sz+1)
crop[left-(xpixcen-sz):right-(xpixcen-sz),bot-(ypixcen-sz):top-(ypixcen-sz)]=im[left:right,bot:top]

;show image
window,1,xsi=2*sz+1,ysi=2*sz+1,xpos=1,retain=2
;nan=where(~finite(crop),ct)
;if ct ne 0 then crop[nan]=median(crop[where(finite(crop))])
tvscl,alog(crop+1)
tvbox,reform(fields[bubble,3:4]/(60.*abs(cd1_1))),sz,sz,angle=-fields[bubble,5],color=!d.n_colors-1,thick=3

;show color jpeg for comparison
num=strtrim(string(bubble),2)
if bubble lt 100 then num='0'+num
if bubble lt 10 then num='0'+num
jpeg=file_search('/users/cnb/glimpse/irac/N'+num+'*.jpg')
read_jpeg,jpeg[0],color,true=3
window,0,xsize=n_elements(color[*,0,0]),ysize=n_elements(color[0,*,0]),retain=2,xpos=1
tvscl,color,true=3

;create a new header
mkhdr,hc,crop
sxaddpar,hc,'CRPIX1',sz
sxaddpar,hc,'CRPIX2',sz
sxaddpar,hc,'CRVAL1',crval1+cd1_1*(xpixcen-crpix1)
sxaddpar,hc,'CRVAL2',crval2+cd2_2*(ypixcen-crpix2)
sxaddpar,hc,'CDELT1',cd1_1
sxaddpar,hc,'CDELT2',cd2_2
sxaddpar,hc,'CTYPE1',sxpar(h,'ctype1')
sxaddpar,hc,'CTYPE2',sxpar(h,'ctype2')

writefits,'/users/cnb/glimpse/fits/'+strtrim(string(bubble),2)+'_'+band+'.fits',crop,hc


theend:
end
