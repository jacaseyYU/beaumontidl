;+
; NAME:
;  SHELLPROFILE
;
; DESCRIPTION:
;  Plots v(theta) for a bubble
;-
pro shellprofile, bubnum

if n_params() eq 0 then bubnum=36
infile='/users/cnb/harp/bubbles/reduced/N'+string(bubnum,format='(i3.3)')+'.fits'
regfile='/users/cnb/analysis/reg/N'+string(bubnum,format='(i3.3)')+'_ell.reg'

if ~file_test(infile) then begin
    print,'FITS file DNE: '+infile
    return
endif

if ~file_test(regfile) then begin
    print,'No elliptical region defined for '+string(bubnum,format='(i3.3)')
    filelist=file_search('/users/cnb/analysis/reg/N*ell.reg')
    print,filelist
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
    print, 'woah!'
    temp=b
    b=a
    a=temp
    a2=a+(a2-b)
endif
    
e1 = sqrt(a^2-b^2)/a
e2 = sqrt(a2^2-(b+a2-a)^2)/a2
emid = sqrt((a+a2)^2/4 - (b+a2/2-a/2)^2)/(a+a2)*2
print, e1, e2, emid, (e1+e2)/2

;- I assume that ast.cd[2,2] is neagative
ast=nextast(h)
if (ast.cd[2,2] ge 0) then stop

sz=ast.sz
hi=round((vlo-ast.crval[2])/ast.cd[2,2]+ast.crpix[2]-1)
lo=round((vhi-ast.crval[2])/ast.cd[2,2]+ast.crpix[2]-1)
hi=hi[0]
lo=lo[0]

sz[2]=(hi-lo+1)

im=im[*,*,lo:hi]
v=findgen(hi-lo+1)*ast.cd[2,2]+vhi
x=findgen(ast.sz[0])
x=rebin(x,sz[0],sz[1])

y=findgen(sz[1])
y=rebin(1#y, sz[0],sz[1])

;-masks
r = sqrt((x-xcen)^2.+(y-ycen)^2.)
theta= atan((y-ycen),(x-xcen))*!radeg - pa

;-snap theta into range 0-360
theta = theta mod 360
bad=where(theta lt 0, ct)
if ct ne 0 then theta[bad]+=360

mask = (r ge b/sqrt(1-e1^2*cos(theta/!radeg)^2)) and (r le (b+a2-a)/sqrt(1-e2^2*cos(theta/!radeg)^2))

window,1,xsize=sz[0]*3,ysize=sz[1]*3,ypos=50

tvscl,congrid(mask,sz[0]*3,sz[1]*3)
tvellipse,a*3,b*3,xcen*3,ycen*3,pa
tvellipse,a2*3,(b+a2-a)*3,xcen*3,ycen*3,pa


vplane=rebin(reform(v,1,1,sz[2]),sz[0],sz[1],sz[2])
mom0=total(im,3,/nan)
normcube=im/rebin(mom0,sz[0],sz[1],sz[2])

mom1=total(normcube*vplane,3,/nan)
mom2=sqrt((total(normcube*vplane^2,3,/nan)-mom1^2)/(1-total(normcube^2,3,/nan)))

tvscl,congrid(mom0,3*sz[0],3*sz[1]),/nan

tvellipse,a*3,b*3,xcen*3,ycen*3,pa
tvellipse,a2*3,(b+a2-a)*3,xcen*3,ycen*3,pa

xyouts,(xcen+a2*cos(pa/!radeg))*3,(ycen+a2*sin(pa/!radeg))*3,'PA=0',/device

theta=theta[where(mask)]
mom1=mom1[where(mask)]
mom2=mom2[where(mask)]

window,2,xpos=50
;-bin data by theta
h=histogram(theta,binsize=10,reverse_indices=ri,locations=loc)
bin1=fltarr(n_elements(loc))
bin2=fltarr(n_elements(loc))
for i=0,n_elements(loc)-1,1 do begin
    if ri[i+1] - ri[i] le 2 then continue
    bin1[i]=median(mom1[ri[ri[i]:ri[i+1]-1]])
    bin2[i]=stdev(mom1[ri[ri[i]:ri[i+1]-1]])
endfor

loc=loc[where(h gt 2)]
bin1=bin1[where(h gt 2)]
bin2=bin2[where(h gt 2)]

plot,loc,bin1,yrange=[.9*min(bin1),1.1*max(bin1)],/ysty,xra=[0,360],/xsty,$
  xtitle='Position Angle (degrees)', ytitle='Mean Velocity (km/s)', charsize=1.5

oploterr,loc,bin1,bin2

;-attempt to fit a sinusoid
;-curvefit doesn't seem to latch on to the phase angle, so find this
;-manually
bestchi = 10d10;
for i=0, 360, 10 do begin
    a = [median(bin1), stdev(bin1), i * !pi/180]
    fita = [1,1,0]
    result = curvefit(loc, bin1, 1/bin2^2, a, sigma, fita=fita, $
                      function_name='sinfit', status=stat, chisq=chisq)
    if stat ne 0 then continue
    if chisq lt bestchi then begin
        bestchi=chisq
        best=a
        bestresult=result
        bestsigma = sigma
    endif
endfor
oplot, loc, bestresult, color='00ff00'xl
xyouts, .5, .9, 'v = A + B *Sin( PA - C)', /norm, charsize = 1.5
xyouts, .5, .85, string(best[0],sigma[0], format="('A = ', i3, '+/-',f 4.1)"), /norm, charsize=1.5
xyouts, .5, .8, string(best[1], sigma[1], format="('B = ', f4.1, '+/-', f4.2)"), /norm, charsize=1.5
xyouts, .5, .75, string(best[2]*180/!pi, format= "('C =', i4)"), /norm, charsize=1.5
xyouts, .5, .7, string((e1+e2)/2., format="('Eccentricity = ', f5.2)"),/norm,charsize=1.5
end

pro sinfit, x, a, f, pder
   f = a[0] + a[1] * sin(x * !pi / 180 - a[2])
   pder = [[replicate(1.0,n_elements(x))], [sin(x*!pi/180 - a[2])], $
           [-a[1]*sin(x*!pi/180 - a[2])]]
end
