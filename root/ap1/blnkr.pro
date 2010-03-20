pro blnkr, bubble

;**********************
;DESCRIPTION: A modification of blnkr. Instead of blinking,
;create an IRAC image with a GRS contour overlay
;
;INPUTS:bubble- A string referencing the bubble to display
;example: 'N21' for bubble 21 in the north catalog
;
;RESTRICTIONS: Only bubbles in the N1 catalog with
;preexisting GRS and IRAS images will work.
;
;**********************


;load bubble info table, extract bubble number from name
readcol,'../glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
       ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
       ,format='a,f,f,f,f,f,f,f,f,f,a',/silent
num=strsplit(bubble,'N',/extract)
numnum=float(num)
number=num[0]
if numnum lt 100 then number='0'+num[0]
if numnum lt 10 then number='00'+num[0]

;scaling information
sz=600.
bub=a_out[numnum-1]*sz/60.

;grs and iras images
read_jpeg,'/users/cnb/glimpse/grs/'+bubble+'_mom1.jpg',im1,true=3
;im1=rebin(im1,164,164,3)

;spitzer irac jpeg
im2=file_search('../irac/N'+number+'*.jpg')
read_jpeg,im2[0],im2,true=3

;make a .75 degree x .75 degree window consisting of 750x750 pixels
;window open?
device,window_state=winstat
if ~winstat[1] then window,1,xs=750,ys=750,retain=2,xpos=0,ypos=1
if ~winstat[2] then window,2,xs=750,ys=750,ret=2,xpos=0,ypos=1
bigim=fltarr(750,750,3)

;irac scale: 1.2"/pix
nx=round(n_elements(im2[*,0,0])/3)
ny=round(n_elements(im2[0,*,0])/3)
im2=congrid(im2,nx,ny,3)
;where is the corner of this image on the big image?
cx=375-nx/2
cy=375-ny/2

;grs scale: 164 pixels=1 degree (6.097 bigim pixels/grs pixel)
im1=congrid(im1,1000,1000,3)
bigim+=im1[126:875,126:875,*]
b2=bigim

bigim[cx:cx+nx-1,cy:cy+ny-1,*]=im2

wset,1
tvscl,bigim,true=3
wset,2
tvscl,b2,true=3
blink,[1,2],1.5

END
