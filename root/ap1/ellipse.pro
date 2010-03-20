pro ellipse, bubnum, recall=recall,total=total,range=range
;-stuff to analyze ellipses

;-load file

file='/users/cnb/harp/bubbles/reduced/N'+string(round(bubnum),format='(i3.3)')+'.fits'
if ~file_test(file) then return

raw=mrdfits(file,0,h,/silent)
ast=nextast(h)
if ~keyword_set(range) then range=[0,ast.sz[2]-1] else $
  range=(range-ast.crval[2])/ast.cd[2,2]+ast.crpix[2]-1

range=range[sort(range)] 
;-make, scale, and display a maxmap
if keyword_set(total) then im=total(raw[*,*,range[0]:range[1]],3,/nan) else $
  im=max(raw[*,*,range[0]:range[1]],dimension=3,/nan)
im=bytscl(im,/nan)

outsz=500
imx=(ast.sz[0] gt ast.sz[1])?500:500.*ast.sz[0]/ast.sz[1]
imy=(ast.sz[0] gt ast.sz[1])?500.*ast.sz[1]/ast.sz[0]:500.
rawim=im
im=congrid(im,imx,imy)

window,1,xsize=imx,ysize=imy,retain=2,ypos=50
tv,im
pick_ellipse:
tv,im

;-interactively find ellipses
cursor,lox,loy,3,/device
cursor,hix,hiy,3,/device
cursor,rightx,righty,3,/device

if (lox ge 400 and hix ge 400 and rightx ge 400) then return

cenx=(hix+lox)/2.
ceny=(hiy+loy)/2.
ax=hix
ay=hiy
bx=rightx
by=righty

;-draw the ellipse on the screen
a=sqrt((ax-cenx)^2+(ay-ceny)^2)
b=sqrt((bx-cenx)^2+(by-ceny)^2)
pa=atan((ay-ceny),(ax-cenx))

tvellipse,a,b,cenx,ceny,pa*!radeg

read,good,prompt='Accept this? (1=yes)
if good ne 1 then goto,pick_ellipse

pick_outer_ellipse:
tv,im
tvellipse,a,b,cenx,ceny,pa*!radeg

;-get outer ellipse
cursor,aoutx,aouty,3,/device
aout=sqrt((aoutx-cenx)^2+(aouty-ceny)^2)
tvellipse,aout,b+(aout-a),cenx,ceny,pa*!radeg

;-draw 'average ellipse' used in shellcontrast
e1=sqrt(a^2-b^2)/a
e2=sqrt(aout^2-(b+aout-a)^2)/aout
ebound=(e1+e2)/2.
thick=(aout-a)/2.
tvellipse, sqrt(((b+thick))^2/(1-ebound^2)), (b+thick),cenx,ceny,pa*!radeg,linestyle=1,color='0000ff'xl



read,good,prompt='Accept this? (1=yes)'
if good ne 1 then goto,pick_outer_ellipse

;-convert quantities to sky coordinates
scale=500./(ast.sz[1]>ast.sz[0])
coords=[cenx,ceny,a,b,aout,pa*!radeg]
coords[0:4]/=scale

;-save ellipse information
outfile='/users/cnb/analysis/reg/N'+string(round(bubnum),format='(i3.3)')+'_ell.reg'
openw,1,outfile
printf,1,coords,format='(6f9.3)'
close,1


end
