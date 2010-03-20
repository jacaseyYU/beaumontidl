;- put an image of the trapezium on top of a bubble (after scaling to
;  the right size and brightness given the distance) to see if we
;  should be able to see bubbles

pro trapezium


trapezium=mrdfits('Trapezium.fits',0,ht,/silent)
tmass=mrdfits('N022_k.fits',0,hb,/silent)
bubble=mrdfits('~/glimpse/fits/i4/22_i4.fits',0,hi,/silent)
stop
cen = [18.256, -0.305]
wid = [.166,.166]
delt = wid / 600.

;- regrid irac to tmass
bubble = postagestamp(bubble,hi,cen,wid,delt)
stop
;- scale
dist = 6.8 ;- bubble 6.8x further away than trapezium
trapezium /= dist^2
sz = size(trapezium)
trapezium = congrid( trapezium, 600. / dist, 600. / dist )


add=tmass
gap=(600-(600/dist))/2.
add[gap,gap]+=trapezium

window,xsize=1200,ysize=1200
tvscl,tmass
tvscl,add,600,0
tvscl,bubble,600,600

end
