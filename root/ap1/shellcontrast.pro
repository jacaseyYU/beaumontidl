pro shellcontrast, bubnum

infile='/users/cnb/harp/bubbles/reduced/N'+string(bubnum,format='(i3.3)')+'.fits'
if ~file_test(infile) then begin
    print,'No JCMT data'
    return
endif

regfile='/users/cnb/analysis/reg/N'+string(bubnum,format='(i3.3)')+'_ell.reg'
if ~file_test(regfile) then begin
    print, 'No elliptical region defined
    files=file_search('/users/cnb/analysis/reg/N*ell.reg')
    print,files
    return
endif

readcol,'/users/cnb/glimpse/pro/bubblemomentmap.txt',n,vlo,vhi,/silent
hit=where(n eq bubnum,ct)
if ct eq 0 then begin
    print,'No velocity boundary information in bubblemomentmap.txt for '+string(bubnum,format='(i3.3)')
    return
endif

vlo=vlo[hit[0]]
vhi=vhi[hit[0]]

im=mrdfits(infile,0,h,/silent)
readcol,regfile,xcen,ycen,a,b,a2,pa,/silent
xcen=xcen[0]
ycen=ycen[0]
a=a[0]
b=b[0]
a2=a2[0]
pa=pa[0]

if b gt a then begin
    temp=b
    b=a
    a=temp
    a2=a+(a2-b)
endif
    
e1 = sqrt(a^2-b^2)/a
e2 = sqrt(a2^2-(b+a2-a)^2)/a2

ast=nextast(h)
sz=ast.sz
lo=round((vlo-ast.crval[2])/ast.cd[2,2]+ast.crpix[2]-1)
hi=round((vhi-ast.crval[2])/ast.cd[2,2]+ast.crpix[2]-1)
hi=hi[0]
lo=lo[0]

sz[2]=(abs(hi-lo)+1)

im=im[*,*,(lo<hi):(lo>hi)]
v=findgen(abs(hi-lo)+1)*ast.cd[2,2]+vlo
x=findgen(ast.sz[0])

x=findgen(ast.sz[0])
x=rebin(x,sz[0],sz[1])

y=findgen(sz[1])
y=rebin(reform(y,1,sz[1]),sz[0],sz[1])

;-masks
r = sqrt((x-xcen)^2.+(y-ycen)^2.)
theta= atan((y-ycen),(x-xcen))*!radeg - pa
ebound=(e1+e2)/2.
thick=(a2-a)/2.
fracrad=r / ( (b+thick)/sqrt(1-ebound^2*cos(theta/!radeg)^2))

shellmask = (r ge b/sqrt(1-e1^2*cos(theta/!radeg)^2)) and (r le (b+a2-a)/sqrt(1-e2^2*cos(theta/!radeg)^2))
inmask = (r lt b/sqrt(1-e1^2*cos(theta/!radeg)^2))


;-snap theta into range 0-360
theta = theta mod 360
bad=where(theta lt 0, ct)
if ct ne 0 then theta[bad]+=360

mom0=total(im,3,/nan)
gooddata=finite(max(im,dimension=3,/nan))
good=where(gooddata)

mom0=mom0[good]
fracrad=fracrad[good]

;-bin moment map by fracrad

h=histogram(fracrad,binsize=0.05,locations=loc,reverse_indices=ri)
data=fltarr(n_elements(h))
for i=0,n_elements(h)-1, 1 do begin
    if ri[i+1] eq ri[i] then continue
    data[i]=median(mom0[ri[ri[i]:ri[i+1]-1]])
endfor

window,1,xsize=600,ysize=400,retain=2,ypos=50
plot,loc,data,xrange=[0,max(loc)],/xsty,psym=4,$
  xtitle='Elliptical Radius',ytitle='Median flux', title='Shell Contrast for Bubble '+string(bubnum,format='(i3.3)')
oplot,loc,data


mag=3.
window,0,xsize=sz[0]*mag,ysize=sz[1]*mag,xpos=0,ypos=350,retain=2
tvscl,congrid(max(im,dimension=3,/nan),mag*sz[0],mag*sz[1]),/nan
for i=.5, 3.,.5 do begin
    tvellipse, sqrt(((b+thick)*mag*i)^2/(1-ebound^2)), (b+thick)*i*mag,xcen*mag,ycen*mag,pa,linestyle=1,color='0000ff'xl
    xyouts,(xcen+(thick+b)*i*sin(pa/!radeg)*(-1))*mag,(ycen+(thick+b)*i*cos(pa/!radeg))*mag,string(i,format='(f3.1)'),/device
endfor

save,file=string(bubnum,format='(i3.3)')+'_shellcontrast.sav', loc, data

end
