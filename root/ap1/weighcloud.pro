pro weighcloud, l, b, vmin, vmax

on_error,2
if n_params() ne 4 then message,'Calling Sequence: weighcloud,l,b,vmin,vmax'

;-make apertures of 10, 20, 30, 40 arcmin, sum the flux

;-load mosaic
lcen=strtrim(string(round(l)),2)
infile='/users/cnb/glimpse/grs/mosaic/'+lcen+'.fits'
if ~file_test(infile) then message,'Error: GRS Mosaic DNE'
im=mrdfits(infile,0,h,/silent)

;-get astrometry
crval1=sxpar(h,'crval1')
crval2=sxpar(h,'crval2')
crval3=sxpar(h,'crval3')
crpix1=sxpar(h,'crpix1')
crpix2=sxpar(h,'crpix2')
crpix3=sxpar(h,'crpix3')
cdelt1=sxpar(h,'cdelt1')
cdelt2=sxpar(h,'cdelt2')
cdelt3=sxpar(h,'cdelt3')
naxis1=sxpar(h,'naxis1')
naxis2=sxpar(h,'naxis2')
naxis3=sxpar(h,'naxis3')

xcen=(l-crval1)/cdelt1+crpix1 - 1
ycen=(b-crval2)/cdelt1+crpix2 - 1
zlow=ceil((vmin*1D3-crval3)/cdelt3+crpix3 - 1)
zhi=floor((vmax*1D3-crval3)/cdelt3+crpix3 - 1)
im=total(im[*,*,zlow:zhi],3,/nan)

;-make aperture masks

xind=rebin(indgen(naxis1),naxis1,naxis2)
yind=rebin(reform(indgen(naxis2), 1, naxis2), naxis1, naxis2)

r10=(10./60./abs(cdelt1))
r20=(20./60./abs(cdelt1))
r30=(30./60./abs(cdelt1))
r40=(40./60./abs(cdelt1))
ap10=((xind-xcen)^2 + (yind-ycen)^2) le r10^2
ap20=((xind-xcen)^2 + (yind-ycen)^2) le r20^2
ap30=((xind-xcen)^2 + (yind-ycen)^2) le r30^2
ap40=((xind-xcen)^2 + (yind-ycen)^2) le r40^2

;window,0,xsi=naxis1,ysi=naxis2,xpos=1300,ypos=50
;tvscl,(ap30 > .5) * im

f1=im*ap10
f2=im*ap20
f3=im*ap30
f4=im*ap40

fill1= total(ap10) 
fill2= total(ap20) 
fill3= total(ap30) 
fill4= total(ap40)

junk=where(~finite(f1),inf1)
junk=where(~finite(f2),inf2)
junk=where(~finite(f3),inf3)
junk=where(~finite(f4),inf4)

print,total(im*ap10,/nan),format='("Total Flux in 10 arcmin aperture mask: ",e9.2, " K m s^-1")'
print,fill1-inf1,format='("Number of Finite Pixels Summed Over: ", i5)'

print,total(im*ap20,/nan),format='("Total Flux in 20 arcmin aperture mask: ",e9.2, " K m s^-1")'
print,fill2-inf2,format='("Number of Finite Pixels Summed Over: ", i5)'


print,total(im*ap30,/nan),format='("Total Flux in 30 arcmin aperture mask: ",e9.2, " K m s^-1")'
print,fill3-inf3,format='("Number of Finite Pixels Summed Over: ", i5)'


print,total(im*ap40,/nan),format='("Total Flux in 40 arcmin aperture mask: ",e9.2, " K m s^-1")'
print,fill4-inf4,format='("Number of Finite Pixels Summed Over: ", i5)'

end




