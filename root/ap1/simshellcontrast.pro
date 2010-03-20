pro simshellcontrast

infile='~/ratran/bubbles/sim/typ.fits'

im=mrdfits(infile,0,h,/silent)

mom0=total(im,3)
sz=size(im)

;-masks
x=rebin(indgen(sz[1]),sz[1],sz[2])
y=rebin(1#indgen(sz[2]),sz[1],sz[2])
r = sqrt((x-sz[1]/2.)^2.+(y-sz[2]/2.)^2.)
fracrad = r / 41.

;-bin moment map by fracrad

h=histogram(fracrad,binsize=0.05,locations=loc,reverse_indices=ri)
data=fltarr(n_elements(h))
for i=0,n_elements(h)-1, 1 do begin
    if ri[i+1] eq ri[i] then continue
    data[i]=median(mom0[ri[ri[i]:ri[i+1]-1]])
endfor

window,1,xsize=600,ysize=400,retain=2,ypos=50
plot,loc,data,xrange=[0,max(loc)],/xsty,psym=4,$
  xtitle='Elliptical Radius',ytitle='Median flux', title='Shell Contrast for Simulated Bubble'
oplot,loc,data


mag=1.
window,0,xsize=sz[1]*mag,ysize=sz[2]*mag,xpos=0,ypos=0,retain=2
tvscl,congrid(mom0,mag*sz[1],mag*sz[2]),/nan
save, loc, data, file='simcontrast.sav'
end
