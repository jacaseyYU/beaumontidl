pro mgim2, cube, plane, vlo, vhi, cdelt, outfile
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
outsize=500.
imx=round((sz[1] gt sz[2])?outsize:sz[1]/sz[2]*outsize)
imy=round((sz[1] gt sz[2])?outsize:sz[2]/sz[1]*outsize)
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
normcube=cube/rebin(mom0,sz[1],sz[2],sz[3])
momnan=where(~finite(mom0) or (mom0 eq 0),ct)
momgood=where(finite(mom0) and (mom0 gt 0))
if ct ne 0 then mom0[momnan]=0
vplane=rebin(reform(findgen(sz[3]),1,1,sz[3]),sz[1],sz[2],sz[3])*(vhi-vlo)/(sz[3]-1)+vlo
mom1=total(normcube*vplane,3)
if ct ne 0 then mom1[momnan]=0
mom2=sqrt((total(normcube*vplane^2,3)-mom1^2)/(1-total(normcube^2,3)))
if ct ne 0 then mom2[momnan]=0

;-scale the moment maps to look pretty. Update velocity info if necessary
;-try to use sigclip for velocity range
mom1max=max(mom1[momgood])
mom1min=min(mom1[momgood])
mom2max=max(mom2[momgood])
mom2min=min(mom2[momgood])
vhi=mom1max
vlo=mom1min
fluxmax=max(mom0)*(vhi-vlo)/sz[3]

range1=findclip(peak[momgood],mom1[momgood],fraction=.99)
mom1=(range1[0] > mom1 < range1[1])
;range2=findclip(peak[momgood],mom2[momgood],fraction=0.85)
range2=[mom2min,mom2max/2.]
mom2=(range2[0] > mom2 < range2[1])
mom0/=max(mom0)
mom1=(mom1-range1[0])/(range1[1]-range1[0])*255.
;mom2=(mom2-range2[0])/(range2[1]-range2[0])*255.
mom2=bytscl(mom2)
mask=peak/max(peak)

;-1st moment color coded max map
im=fltarr(sz[1],sz[2],3)
im[*,*,0]=(0.6*r[mom1]+0.4*255.)*mask
im[*,*,1]=(0.6*g[mom1]+0.4*255.)*mask
im[*,*,2]=(0.6*b[mom1]+0.4*255.)*mask

;-dispersion-color coded max map
im3=fltarr(sz[1],sz[2],3)
im3[*,*,0]=(0.6*r[mom2]+0.4*255.)*mask
im3[*,*,1]=(0.6*g[mom2]+0.4*255.)*mask
im3[*,*,2]=(0.6*b[mom2]+0.4*255.)*mask

;-regrid output image to desired size
im=congrid(im,imx,imy,3,cubic=-0.5)
im3=congrid(im3,imx,imy,3)
im5=congrid(plane,imx,imy)

;-output files
max1='figures/'+outfile+'_max1.bmp'
max2='figures/'+outfile+'_max2.bmp'
irac1='figures/'+outfile+'_irac1.bmp'
irac2='figures/'+outfile+'_irac2.bmp'
moment0='figures/'+outfile+'_mom0.bmp'
maxmap='figures/'+outfile+'_max.bmp'

write_bmp,moment0,bytscl(mom0)
write_bmp,maxmap,bytscl(peak)

;-make output window
window,1,xsize=szx,ysize=szy,retain=2,ypos=100
tv,im,borderx/2.,bordery/2.,true=3

;-moment 1 color bar
barind=fltarr(barx)
loclip=floor((range1[0]-mom1min)/(mom1max-mom1min)*barx)
hiclip=floor((range1[1]-mom1min)/(mom1max-mom1min)*barx)
barind[loclip:hiclip]=findgen(hiclip-loclip+1)/(hiclip-loclip)
barind[hiclip:barx-1]=1
barind=rebin(bytscl(barind),barx,bary)
bar=bytarr(barx,bary,3)
bar[*,*,0]=r[barind]
bar[*,*,1]=g[barind]
bar[*,*,2]=b[barind]
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

out=tvrd(true=1)
write_bmp,max1,out


tv,im5,borderx/2.,bordery/2.
out=tvrd(true=1)
write_bmp,irac1,out

;-redo for dispersion
erase
tv,im3,borderx/2.,bordery/2.,true=3

;-color bar for moment 2
barind=fltarr(barx)
loclip=floor((range2[0]-mom2min)/(mom2max-mom2min)*barx) > 0
hiclip=floor((range2[1]-mom2min)/(mom2max-mom2min)*barx) < barx-1
barind[loclip:hiclip]=findgen(hiclip-loclip+1)/(hiclip-loclip)
barind[hiclip:barx-1]=1
barind=rebin(bytscl(barind),barx,bary)

bar=bytarr(barx,bary,3)
bar[*,*,0]=r[barind]
bar[*,*,1]=g[barind]
bar[*,*,2]=b[barind]
tv,bar,borderx/2,bordery/2+imy+gapy,true=3
;-annotate the colorbar
xyouts,(borderx+imx)/2,3./4*bordery+gapy+bary+imy,'Velocity Dispersion (km/s)',/device,alignment=0.5
nticks=7
left=borderx/2
right=imx+borderx/2
bot=bordery/2+gapy+imy
top=bot+bary
plots,[left,right,right,left,left],[bot,bot,top,top,bot],/device
for i=0,nticks-1,1 do begin
    plots,(left+barx/(nticks-1.)*i)*[1,1],[bot,bot+bary/10],/device
    if (i eq 0) then a=0 else if (i eq nticks-1) then a=1 else a=0.5
    xyouts,left+barx/(nticks-1.)*i,bot-gapy/2,strtrim(string(mom2min+(mom2max-mom2min)/(nticks-1.)*i,format='(f5.1)'),2),/device,alignment=a
endfor

out=tvrd(true=1)
write_bmp,max2,out

;tv,im4,borderx/2.,bordery/2.,true=3
;out=tvrd(true=2)
;write_bmp,irac2,out

end

