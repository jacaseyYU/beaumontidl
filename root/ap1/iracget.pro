PRO iracget,bubble

;********************
;DESCRIPTION: iracget downloads from the web
;an GLIMPSE FITS mosaic containing a bubble
;it then trims the large file and creates
;a smaller FITS file of the region
;directly around the bubble
;
;INPUTS: Bubble- the number of a bubble
;in the Churchwell N1 catalog.
;
;OUTPUTS:A large (~200MB) fits image
;of the GLIMPSE mosaic containing Bubble,
;and a smaller fits file displaying
;just the bubble
;
;NOTES:The program checks to see if the
;mosaic fits exists and, if it does, 
;skips the download
;*************************


readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a',/silent

sz=r[bubble-1]/60.
l=l[bubble-1]
b=b[bubble-1]


;parse together URL
url='http://data.spitzer.caltech.edu/popular/glimpse/20070416_enhanced_v2/3.1x2.4_mosaics/'
lon=floor(l/3.)*3
dir='GLON_53-65/'
if lon lt 53 then dir='GLON_30-53/'
if lon lt 30 then dir='GLON_10-30/'

lon*=100
file=strtrim(string(lon),2)
if lon lt 10000 then file='0'+file
if lon lt 1000 then file='0'+file
file='GLM_'+file+'+0000_mosaic_I1'

fits=url+dir+file+'.fits'
hdr=url+dir+file+'.hdr'

;check for fits file
present=file_test('/users/cnb/glimpse/N'+strtrim(string(bubble),2)+'.fits')
if ~ present then begin
    print,'Downloading the following file: '
    print,fits
    spawn,'curl '+fits+' > N'+strtrim(string(bubble),2)+'.fits'
endif else begin
    print,'Mosaic already downloaded'
endelse

spawn,'curl '+hdr, head
crpix1=sxpar(head,'crpix1')
crpix2=sxpar(head,'crpix2')
crval1=sxpar(head,'crval1')
crval2=sxpar(head,'crval2')
naxis1=sxpar(head,'naxis1')
naxis2=sxpar(head,'naxis2')

scale=2.
adxy,head,l,b,x,y
dx=scale*sz*3600./1.2
x=round(x)
y=round(y)
dx=round(dx)
left=x-dx
right=x+dx
bot=y-dx
top=y+dx

print, 'Boundaries (l,r,b,t)'
print,left,right,bot,top
print,'master image dimensions'
print,naxis1,naxis2

if ((left lt 0) or (bot lt 0) or (right ge naxis1) or (top ge naxis2)) then begin
    print,'Bubble not contained in this file. Aborting.'
    return
endif


fits=mrdfits('N'+strtrim(string(bubble),2)+'.fits',0,/fscale,/silent)
fits=fits[left:right,bot:top]
output='/users/cnb/glimpse/irac/N'+strtrim(string(bubble),2)+'.fits'
if file_test(output) then spawn,'rm -f '+output
mwrfits,fits,'/users/cnb/glimpse/irac/N'+strtrim(string(bubble),2)+'.fits'



END
