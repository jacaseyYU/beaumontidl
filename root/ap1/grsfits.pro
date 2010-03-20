pro grsfits,bubble
;**************************
;for bubble, create a cropped fits imagage from the GRS
;mosaic. If necessary, download the mosaic. Create a new header, and
;save the file
;
;UPDATE: June 4: Created this by modifying bubblefits.pro- used for spitzer
;
;**************************

;determine image properties
restore,file='fields.sav'
xcen=fields[bubble,1]
ycen=fields[bubble,2]
sz=1.5*sqrt(fields[bubble,3]^2+fields[bubble,4]^2)/(2.*60.)

;mosaic index info
lcen=15+indgen(21)*2

;find best fit mosaic
in=where(abs(lcen-xcen)  eq  min(abs(lcen-xcen)))

;make sure the bubble is inside
if abs(lcen[in]-xcen) ge 1 then begin
    print, 'error: bad bubble location'
    goto, theend
endif

;parse together filename
num=strtrim(string(lcen[in]),2)
num=num[0]
dir='grs-stitch/source/'

url='http://grunt.bu.edu/'
file='grs-'+num+'-cube.fits'

;do we already have the fits file?
test=file_test('/users/cnb/glimpse/grs/mosaic/'+num+'.fits')

if test then begin
    print,'mosaic already downloaded. continuing...'
endif else begin
    print,'downloading mosaic from web...'
    stop
    spawn, 'curl '+url+dir+file+'.fits > /users/cnb/glimpse/grs/'+num+'.fits'
endelse

;read in file
im=mrdfits('/users/cnb/glimpse/grs/mosaic/'+num+'.fits',0,h)
nx=n_elements(im[*,0,0])
ny=n_elements(im[0,*,0])
nz=n_elements(im[0,0,*])

;extract bubble region

crval1=sxpar(h,'crval1')
crval2=sxpar(h,'crval2')
crpix1=sxpar(h,'crpix1')
crpix2=sxpar(h,'crpix2')
cd1_1=sxpar(h,'cdelt1')
cd2_2=sxpar(h,'cdelt2')
cd3_3=sxpar(h,'cdelt3')
crval3=sxpar(h,'crval3')
crpix3=sxpar(h,'crpix3')

xpixcen=round((xcen-crval1)/cd1_1+crpix1)
ypixcen=round((ycen-crval2)/cd2_2+crpix2)
sz=round(sz/abs(cd1_1))            ;assuming square pixels here

top=min([ny-1,ypixcen+sz])
bot=max([0,ypixcen-sz])
left=max([0,xpixcen-sz])
right=min([nx-1,xpixcen+sz])

crop=fltarr(2*sz+1,2*sz+1,nz)
crop[left-(xpixcen-sz):right-(xpixcen-sz),bot-(ypixcen-sz):top-(ypixcen-sz),*]=im[left:right,bot:top,*]


;create a new header
mkhdr,hc,crop
sxaddpar,hc,'CRPIX1',sz
sxaddpar,hc,'CRPIX2',sz
sxaddpar,hc,'CRVAL1',crval1+cd1_1*(xpixcen-crpix1)
sxaddpar,hc,'CRVAL2',crval2+cd2_2*(ypixcen-crpix2)
sxaddpar,hc,'CDELT1',cd1_1
sxaddpar,hc,'CDELT2',cd2_2
sxaddpar,hc,'CRPIX3',crpix3
sxaddpar,hc,'CRVAL3',crval3
sxaddpar,hc,'CDELT3',cd3_3
sxaddpar,hc,'CTYPE1',sxpar(h,'ctype1')
sxaddpar,hc,'CTYPE2',sxpar(h,'ctype2')
sxaddpar,hc,'CTYPE3',sxpar(h,'ctype3')

writefits,'/users/cnb/glimpse/grs/'+strtrim(string(bubble),2)+'.fits',crop,hc


theend:
end
