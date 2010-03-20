pro mgim3, cube, plane, vlo, vhi, cdelt, outfile
;- Moment map and Greyscale Image Mashup

sz=size(cube)

;-velocity step size in cube
cdelt3=(vhi-vlo)/sz[3]

;-create moment maps.
peak=max(cube,dimension=3,/nan)
mom0=total(cube,3,/nan)
normcube=cube/rebin(mom0,sz[1],sz[2],sz[3])

mombad=where(mom0 le 0, ct)

vplane=rebin(reform(findgen(sz[3]),1,1,sz[3]),sz[1],sz[2],sz[3])*(vhi-vlo)/(sz[3]-1)+vlo
mom1=total(normcube*vplane,3,/nan)
if ct ne 0 then mom1[mombad]=!values.f_nan

mom2=sqrt((total(normcube*vplane^2,3,/nan)-mom1^2)/(1-total(normcube^2,3,/nan)))
if ct ne 0 then mom2[mombad]=!values.f_nan

safepeak=peak
momdisp,peak,mom1,'/users/cnb/figures/'+outfile+'_mom1.png',clo=vlo,chi=vhi
peak=safepeak
momdisp,peak,mom2,'/users/cnb/figures/'+outfile+'_mom2.png',ct=20,clo=0.,chi=(vhi-vlo)
end

