function tr2av, data, dataerr, dist

;- data is [j,h,k,1,2,3,4] magnitudes
;- dataerr is 1 sigma uncertainty on these
;- fit  tr^2 and Av to data, assuming a Rayleigh-Jeans spectrum

;-magnitude zero points in Janskys
;-Glimpse 2.0 DR Document, p17
zero=[1594, 1024, 666.7, 280.9, 179.7, 115.0, 64.13]
zero*=(1D-26) ;- convert Janskys to SI units

;-Constants
kpc2met = 3.086d19
c = 3d8
kb = 1.38d-23

;-frequencies of each filter. From Indebetouw et al 2004
nu=[1.24, 1.664, 2.164, 3.545, 4.442, 5.675, 7.760]*1D-6
nu=c/nu

;-Ratio of Alambda/Av. From Rieke and Lebofsky 1985 ApJ 288 618
a=[2.50, 1.55, 1.00, 0.56, 0.43, 0.43, 0.43]*0.112

;-make a grid of possible Avs, TR2s
avs=findgen(240)/4.
tr2s=[1., 2., 5., 10., 20., 50., 100., 200., 500., 1000., 2000., 5000., 10000., 20000., 50000.,100000., 200000., 500000.]*1D21
nx=240
ny=18
nz=7

avs=rebin(avs,nx,ny,nz)
tr2s=rebin(transpose(tr2s),nx,ny,nz)
nu=rebin(reform(nu,1,1,nz),nx,ny,nz)
zero=rebin(reform(zero,1,1,nz),nx,ny,nz)
a=rebin(reform(a,1,1,nz),nx,ny,nz)

;-determine which bands have data
good=where(data le 99)

;-calculate Least Squares
model = 2.5*alog10( zero * (c * dist * kpc2met)^2 / (2 * kb * tr2s * !pi * nu^2 ) ) + avs * a
datagrid=rebin(reform(data,1,1,nz),nx,ny,nz)
resid= total( abs(datagrid[*,*,good]-model[*,*,good]),3 )

chimin=min(resid)
goal=total(dataerr[good])
c1=chimin+goal
c2=chimin+2*goal
c3=chimin+3*goal


;-display Chi Squared
;window,0,xpos=1350,ypos=50,xsize=500,ysize=500,retain=2
;xt=findgen(nx/20)*6
;yt=findgen(ny/2)*2
;contour,resid, levels=[c1,c2,c3]

;print, min(resid)/goal
ind=where(resid eq min(resid))
ind=array_indices([nx,ny],ind,/dimensions)
;print,avs[ind[0],ind[1],0]
result=tr2s[ind[0],ind[1],0]


;window,1,xpos=1850,ypos=50,retain=2,xsize=300,ysize=300
;plot,data,yra=[.9*min(data),1.1*max(data)],xra=[-.1,6.1],/xsty,/ysty
;oploterr,data,dataerr,1
;oplot,model[ind[0],ind[1],*],psym=4,color='ffff00'xl
;plot,(data-model[ind[0],ind[1],*])/dataerr

return,result

end
