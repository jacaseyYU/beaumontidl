;  - this manually adds missing astrometry info to some of the
;    corrupted bubble fits files

pro addhead

dir ='/users/cnb/harp/bubbles/reduced/'
n=['N016','N039','N049','N054','N046','N090']
cp1=[81,64,48,55,42,63]
cp2=[78,61,49,53,45,68]
cd=[6,6.00002,6.00005,6.00008,6.00001,6.00001]/3600.
cv1=[14.9763, 25.3616, 28.8296, 31.1564, 27.3077, 43.7582]
cv2=[.0547333, -.147733, -.228333, .295467, -.121933, .0848]
vlo=[89.8985, 129.9011, 129.9005, 129.9019, 129.9012, 99.90144]
vhi=[-24.9015, -9.898893, -19.89947, 0.1018603, -9.898837, 20.10144]



for i=0,n_elements(n)-1, 1 do begin
    infile=dir+'fits_nohead/'+n[i]+'.fits'
    im=mrdfits(infile,0,h,/silent)
    sz=size(im)
    sxaddpar,h,'crval1',cv1[i]
    sxaddpar,h,'crval2',cv2[i]
    sxaddpar,h,'cdelt1',cd[i]*(-1.)
    sxaddpar,h,'cdelt2',cd[i]
    sxaddpar,h,'crpix1',cp1[i]
    sxaddpar,h,'crpix2',cp2[i]
    sxaddpar,h,'crval3',(vlo[i]+vhi[i])/2.
    sxaddpar,h,'crpix3',(sz[3]+1)/2.
    sxaddpar,h,'cdelt3',(vhi[i]-vlo[i]*1.0)/(sz[3]-1.)
    writefits,dir+n[i]+'.fits',im,h
endfor

end
