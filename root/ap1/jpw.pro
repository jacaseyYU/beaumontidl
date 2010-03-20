pro jpw
;-figure for bubble 36


;- IMAGE TWEAKS
VLO= 98. ;100
VHI= 120.
PA = 40.
VCLIPLO=105. ; 103
VCLIPHI=111.5 ; 113
LOX=190
HIX=607
LOY=151
HIY=600

vcen=(vlo+vhi)/2.
vwid=(vhi-vlo)/2.

;-FILES
jcmt='/users/cnb/harp/bubbles/reduced/N036.fits'
irac4='/users/cnb/glimpse/fits/I4/36_I4.fits'
irac3='/users/cnb/glimpse/fits/I3/36_I3.fits'
magpis='/users/cnb/magpis/20/036.fits'

jcmt=mrdfits(jcmt,0,hjc,/silent)
irac4=mrdfits(irac4,0,hi4,/silent)
irac3=mrdfits(irac3,0,hi3,/silent)
magpis=mrdfits(magpis,0,hma,/silent)
asti=nextast(hi4)
astj=nextast(hjc)
pixscale=abs(asti.cd[1,1])

;-REGRID IMAGES
cen=[astj.crval[0],astj.crval[1]]
wid=[astj.cd[1,1],astj.cd[1,1]]*[astj.sz[0],astj.sz[1]]
scale=[asti.cd[0,0],asti.cd[1,1]]


irac4=postagestamp(irac4,hi3,cen,wid,scale,/nan)
irac3=postagestamp(irac3,hi3,cen,wid,scale,/nan)
magpis=postagestamp(magpis,hma,cen,wid,scale,/nan)
jcmt=postagestamp(jcmt,hjc,[cen[0],cen[1],vcen],[wid[0],wid[1],vwid],[scale[0],scale[1],.2],/nan)

;-COLLAPSE AND SMOOTH JCMT MAP
sz=size(jcmt)
mom0=total(jcmt,3,/nan)
normcube=jcmt/rebin(mom0,sz[1],sz[2],sz[3])
vplane=(findgen(sz[3])-((sz[3]-1)/2.))*0.2+vcen
vplane=rebin(reform(vplane,1,1,sz[3]),sz[1],sz[2],sz[3])
mom1=total(normcube*vplane,3,/nan)

jcmt=max(jcmt,dimension=3,/nan)
bad=where(~finite(jcmt))
jcmt[bad]=0
psf=psf_gaussian(npixel=20,fwhm=4,/normalize)
jcmt=convolve(jcmt,psf)
mom1=convolve(mom1,psf)

;-ROTATE AND TRIM
mom0=rot(mom0,pa,cubic=0.5)
mom1=rot(mom1,pa,cubic=0.5)
irac4=rot(irac4,pa,cubic=0.5)
irac3=rot(irac3,pa,cubic=0.5)
magpis=rot(magpis,pa,cubic=0.5)
jcmt=rot(jcmt,pa,cubic=0.5)

;tvscl,jcmt,/nan
;while 1 do begin
;    cursor,x,y,/device,/down
;    print,x,y
;endwhile

irac4=irac4[lox:hix,loy:hiy]
irac3=irac3[lox:hix,loy:hiy]
jcmt=jcmt[lox:hix,loy:hiy]
magpis=magpis[lox:hix,loy:hiy]
mom0=mom0[lox:hix,loy:hiy]
mom1=mom1[lox:hix,loy:hiy]

;-CHANGE NANS TO ZEROS
n0=where(~finite(irac4),ct0)
n1=where(~finite(irac3),ct1)
n2=where(~finite(magpis),ct2)
n3=where(~finite(mom0),ct3)
n4=where(~finite(mom1),ct4)

if ct0 ne 0 then irac4[n0]=min(irac4,/nan)
if ct1 ne 0 then irac3[n1]=min(irac3,/nan)
if ct2 ne 0 then magpis[n2]=min(magpis,/nan)
if ct3 ne 0 then mom0[n3]=0
if ct4 ne 0 then mom1[n4]=0

;-SIGRANGE ON IRAC IMAGES
irac4=sigrange(irac4,fraction=0.998)
irac3=sigrange(irac3,fraction=0.995)

;-BYTSCALE IMAGES
irac4=bytscl(irac4)
irac3=bytscl(irac3)
jcmt=bytscl(jcmt)
magpis=bytscl(magpis)


;-FINAL, MANUAL TWEAKS
magpis=bytscl(sqrt((4 > magpis < 150)))
jcmt = bytscl(8 > jcmt < 240)
mom1 = bytscl ( vcliplo > mom1 < vcliphi )


;-COLOR SCHEMES
mcol=[255,0,0]/255.
jcol=[30,255,30]/255.
i3col=[200,0,255]/255.
i4col=[0,0,255]/255.

;-THREE COLOR IMAGE
sz=size(jcmt)
final=bytarr(3,sz[1],sz[2])

mcol=rebin(mcol,3,sz[1],sz[2])
jcol=rebin(jcol,3,sz[1],sz[2])
i3col=rebin(i3col,3,sz[1],sz[2])
i4col=rebin(i4col,3,sz[1],sz[2])

;-COLOR WEIGHTS
jw=2.0
i3w=1.0
i4w=3.8
mw=2.5

magpis=rebin(reform(magpis,1,sz[1],sz[2]),3,sz[1],sz[2])
jcmt=rebin(reform(jcmt,1,sz[1],sz[2]),3,sz[1],sz[2])
irac3=rebin(reform(irac3,1,sz[1],sz[2]),3,sz[1],sz[2])
irac4=rebin(reform(irac4,1,sz[1],sz[2]),3,sz[1],sz[2])

final=mcol*magpis*mw+jcol*jcmt*jw+i4col*irac4*i4w
;final=sigrange(final,fraction=0.982)

window,0,xsize=sz[1],ysize=sz[2],retain=2,ypos=200
tvscl,sigrange(final,fraction=.982),/true

;-ADD A SCALE BAR
dx=100
plots,[20,20+dx],[20,20],/device
plots,[20,20],[10,30],/device
plots,[20+dx,20+dx],[10,30],/device
xyouts,(40+dx)/2.,10,'2 arcminutes', /device,alignment=0.5

xyouts,10,sz[2]-15,'Bubble N036',/device
xyouts,10,sz[2]-30,'l=24.83, b=0.10',/device

xyouts,sz[1]-10,45,'Red: MAGPIS 6cm continuum',/device,alignment=1
xyouts,sz[1]-10,30,'Green: JCMT HARP CO 3-2',/device,alignment=1
xyouts,sz[1]-10,15,'Blue: IRAC 8 micron',/device,alignment=1



write_png,'/users/cnb/figures/jpw_pretty_bright.png',bytscl(sigrange(final,fraction=0.98))
write_png,'/users/cnb/figures/jpw_pretty_dim.png',bytscl(sigrange(final,fraction=0.996))

;-MOMENT MAP
colormoment=fltarr(3,sz[1],sz[2])
loadct,34
tvlct,r,g,b,/get

bw=1.0*jcmt[0,*,*]/max(jcmt[0,*,*])
colormoment[0,*,*]=1.0*r[mom1]*bw
colormoment[1,*,*]=1.0*g[mom1]*bw
colormoment[2,*,*]=1.0*b[mom1]*bw

tv,colormoment,/true
;- add a colorbar
dy=40
left=0
right=sz[1]-1
top=sz[2]-1
bot=top-dy
colorbar=rebin(findgen(sz[1])*255./(sz[1]-1.),sz[1],dy)
cb=fltarr(3,sz[1],dy)
cb[0,*,*]=r[colorbar]
cb[1,*,*]=g[colorbar]
cb[2,*,*]=b[colorbar]
tv,cb,left,bot,/true
plots,[left,right,right,left,left],[bot,bot,top,top,bot],/device
xyouts,sz[1]/2,bot-20,'Radial Velocity (km/s)', alignment=0.5,/device
for i=0,6, 1 do begin
    plots,left+(right-left)*i/6.*[1,1],[bot,bot+10],/device
    alignment=0.5
    if i eq 0 then alignment = 0
    if i eq 6 then alignment = 1
    xyouts,left+(right-left)*i/6.,bot-10.,string(vcliplo+(vcliphi-vcliplo)/6.*i,format='(f5.1)'),alignment=alignment,/device
endfor

out=tvrd(/true)
write_png,'/users/cnb/figures/jpw_doppler.png',out
end

