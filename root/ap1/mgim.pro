pro mgim, cube, plane, vlo, vhi, cdelt, outfile
;- Moment map and Greyscale Image Mashup

lo=0
hi=n_elements(cube[0,0,*])-1

;-flag and scale Plane image
bad=where(~finite(plane),ct)
if ct ne 0 then plane[bad]=0
;plane=sigrange(plane,fraction=0.99)
plane=bytscl(hist_equal(plane))


;-load a color table and get the RGB colors
loadct,34,/silent
tvlct,r,g,b,/get

;-input/output size information
sz=size(cube)
sz[3]=(hi-lo+1)
cube=cube[*,*,lo:hi]
outsize=400.
imx=round((sz[1] gt sz[2])?outsize:sz[1]/sz[2]*outsize)*2
imy=round((sz[1] gt sz[2])?outsize:sz[2]/sz[1]*outsize)*2
barx=imx
bary=imy/10
borderx=50
bordery=50
gapy=30
szx=imx+borderx
szy=imy+bordery+gapy+bary

;-velocity step size in cube
cdelt3=(vhi-vlo)/sz[3]
cdelt/=(outsize/(sz[1]>sz[2]))

;-flag NANs in cube to zero
cubenan=where(~finite(cube) or (cube lt 0),ct)
if ct ne 0 then cube[cubenan]=0

;-create moment maps.
peak=max(cube,dimension=3)
mom0=total(cube,3)
momnan=where(~finite(mom0) or (mom0 eq 0),ct)
if ct ne 0 then mom0[momnan]=0
vplane=rebin(reform(findgen(sz[3]),1,1,sz[3]),sz[1],sz[2],sz[3])
mom1=total(cube*vplane,3)/mom0
if ct ne 0 then mom1[momnan]=0
;mom2=sqrt(total((cube*vplane/total(cube)-rebin(mom1,sz[1],sz[2],sz[3]))^2,3))

;-scale the moment maps to look pretty. Update velocity info if necessary

;-try to use sigclip for velocity range
;range=findclip(peak,mom1,fraction=.99,/nozero)
;mom1=(range[0] > mom1 < range[1])
fluxmax=max(mom0)*(vhi-vlo+1.)/sz[3]
;mom0=sigrange(sqrt(mom0),fraction=0.995)
mom0/=max(mom0)
mom0=sqrt(mom0)
mom1max=max(mom1)
mom1min=min(mom1)
mom1=(mom1-mom1min)/(mom1max-mom1min)*255
vhi=vlo+mom1max*cdelt3
vlo=vlo+mom1min*cdelt3

;mask=mom0
mask=peak/max(peak)

im=fltarr(sz[1],sz[2],3)
im[*,*,0]=r[mom1]*mask*(mask)+plane*(1-mask)
im[*,*,1]=g[mom1]*mask*(mask)+plane*(1-mask)
im[*,*,2]=b[mom1]*mask*(mask)+plane*(1-mask)

im1=rebin(plane,sz[1],sz[2],3)
im2=rebin(mom0,sz[1],sz[2],3)*255

im3=fltarr(sz[1],sz[2],3)
im3[*,*,0]=r[mom1]
im3[*,*,1]=g[mom1]
im3[*,*,2]=b[mom1]

;-regrid output image to desired size
im=congrid(im,imx/2,imy/2,3,cubic=-0.5)
im1=congrid(im1,imx/2,imy/2,3)
im2=congrid(im2,imx/2,imy/2,3)
im3=congrid(im3,imx/2,imy/2,3)

;-make output window
window,1,xsize=szx,ysize=szy,retain=2,ypos=100,xpos=0

;-create a colorbar
barind=rebin(bytscl(findgen(barx)),barx,bary)
bar=bytarr(barx,bary,3)
bar[*,*,0]=r[barind]
bar[*,*,1]=g[barind]
bar[*,*,2]=b[barind]

;-display image with colorbar
tv,im,borderx/2+imx/2,bordery/2,true=3
tv,im1,borderx/2,bordery/2+imy/2,true=3
tv,im2,borderx/2+imx/2,bordery/2+imy/2,true=3
tv,im3,borderx/2,bordery/2,true=3

tv,bar,borderx/2,bordery/2+imy+gapy,true=3
;-annotate the colorbar
xyouts,(borderx+imx)/2,3./4*bordery+gapy+bary+imy,'Mean Velocity (km/s)',/device,alignment=0.5
nticks=7
left=borderx/2
right=imx+borderx/2
bot=bordery/2+gapy+imy
top=bot+bary
plots,[left,right,right,left,left],[bot,bot,top,top,bot],/device
for i=0,nticks-1,1 do begin
    plots,(left+barx/(nticks-1.)*i)*[1,1],[bot,bot+bary/10],/device
    if (i eq 0) then a=0 else if (i eq nticks-1) then a=1 else a=0.5
    xyouts,left+barx/(nticks-1.)*i,bot-gapy/2,strtrim(string(vlo+(vhi-vlo)/(nticks-1.)*i,format='(f5.1)'),2),/device,alignment=a
endfor

goto, skipscalebar
;-create a scale bar
barind=rebin(reform(bytscl(findgen(barx)),1,barx),bary,barx)
barind/=255.
checkerboard=indgen(bary/10,barx/10)
checkerboard=(checkerboard mod 2) eq 0
checkerboard=congrid(checkerboard,bary,barx)
bar=bytarr(bary,barx,3)
bar[*,*,0]=255*barind+100*checkerboard*(1-barind)
bar[*,*,1]=100*(1-barind)*checkerboard
bar[*,*,2]=100*(1-barind)*checkerboard
tv,bar,borderx/2+gapy+imx,bordery/2,true=3

;-annotate scale bar
xyouts,szx-1*borderx/4,(bordery+imy)/2,'Integrated Intensity (K km/s)',$
	/device,alignment=0.5,orientation=-90
nticks=7
left=borderx/2+imx+gapy
right= left+bary
bot=borderx/2
top=bot+barx
plots,[left,right,right,left,left],[bot,bot,top,top,bot],/device
for i=0,nticks-1,1 do begin
    plots,[left,left+bary/10.],(bot+(top-bot)/(nticks-1)*i)*[1,1],/device
    if (i eq 0) then a=1 else if (i eq nticks-1) then a=0 else a=0.5
    xyouts,left-gapy/2., bot+(top-bot)/(nticks-1.)*i,strtrim(string(fluxmax/(nticks-1.)*i,format='(i3)'),2),$
      /device,alignment=a,orientation=-90
endfor

skipscalebar:

;-make a 1 arcmin ruler
plots,[borderx,borderx+1/60./cdelt],[bordery,bordery],/device
xyouts,borderx,bordery+5,'10 arcmin',/device
out=tvrd(true=1)

test=fltarr(sz[1],sz[2],3)
test[*,*,0]=(.4*r[mom1]/255.+.6)*plane
test[*,*,1]=(.4*g[mom1]/255.+.6)*plane
test[*,*,2]=(.4*b[mom1]/255.+.6)*plane

test2=test
test2[*,*,0]=(.6*r[mom1]/255.+.4)*mask*255
test2[*,*,1]=(.6*g[mom1]/255.+.4)*mask*255
test2[*,*,2]=(.6*b[mom1]/255.+.4)*mask*255


stop
write_bmp,outfile,out


end

