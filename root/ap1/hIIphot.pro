pro HIIphot

;-using hand-defined elliptical annuli, measure flux in 20cm HII
;regions for different bubbles. 

;- our hand defined catalog
cat='/users/cnb/glimpse/pro/obslog.csv'
readcol,cat,bubble,morphology,ambiguity,hii,xcen,ycen,outa,outb,ina,pa,skipline=3,format='(i3.3,A20,i2,i2,i3,i3,i3,i3,i3,i3)'

nrec=n_elements(xcen)
flux=fltarr(nrec)-1
peak=fltarr(nrec)
avg=fltarr(nrec)
lat = fltarr(nrec)
lon = fltarr(nrec)
radii = fltarr(nrec)

for i=0, nrec-1, 1 do begin
    if hii[i] ne 1 then begin
        print,'No HII region: skipping', bubble[i]
        continue
    endif
    infile='/users/cnb/magpis/20/'+string(bubble[i],format='(i3.3)')+'.fits'
    im=mrdfits(infile,0,h,/silent)

    ast = nextast(h)
    lon[i] = (xcen[i] - ast.crpix[0]) * ast.cd[0,0] + ast.crval[0]
    lat[i] = (ycen[i] - ast.crpix[1]) * ast.cd[1,1] + ast.crval[1]

    maj = sxpar(h,'bmaj') / 2.355
    min = sxpar(h,'bmin') / 2.355
    pix = sxpar(h, 'cdelt2')
    print, pix*3600.
    beamsize = 2* !pi * maj * min
    ;-convert to Jy / Pix
    im *= (abs(pix^2.) / beamsize )
    sz=size(im)
    
;coordinates
    x=rebin(findgen(sz[1]),sz[1],sz[2])
    y=rebin(reform(findgen(sz[2]),1,sz[2]),sz[1],sz[2])
    
;masks
    r=sqrt((x-xcen[i])^2 + (y-ycen[i])^2)
    theta=atan((y-ycen[i]),(x-xcen[i]))
    theta-=pa[i]/!radeg
    a=outa[i]
    b=outb[i]
    ain=ina[i]
    bin=b+(ain-a)
    radii[i] = (ain + bin)/2. * pix * 60

    in = r le (ain*bin)/sqrt(ain^2*sin(theta)^2+bin^2*cos(theta)^2)
    in = (in and finite(im))
    shell = ~in and (r le (a*b)/sqrt(a^2*sin(theta)^2+b^2*cos(theta)^2))
    shell = (shell and finite(im))
    areain=total(in)*1.0
    areashell=total(shell)*1.0
    
;display image
   ; window,1,ypos=50,retain=2,xsize=sz[1],ysize=sz[2]
   ; tvscl,sigrange(im,fraction=.995) * (shell > 0.5)
    

;-photometry
    flux[i]=total(im*in,/nan)-total(im*shell,/nan)*areain/areashell
;    print, total(im*in,/nan), total(im*shell,/nan)*areain/areashell
    peak[i]=max(im*in)-median(im*shell)
    avg[i]=flux[i]/areain

;    print, lon[i], lat[i], flux[i]
 ;   stop
endfor


print, transpose([[bubble],[lon],[lat],[flux]]), $
  format="(i3.3,2x, f8.3, 2x, f8.3, 2x, e8.1)"

stop

openw, 1, 'hIIfluxes.dat'
printf, 1,'Bubble Number & HII Flux (Jy) \\'
printf, 1, transpose([[bubble],[radii], [flux]]), format="(i3.3, ' ', f4.1, ' ', e8.1)"
close,1
end
