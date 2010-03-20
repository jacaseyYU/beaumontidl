pro refspec

;takes a list of reference pointings- assumed to have
;little or no emission- and creates spectra from the GRS 
;data cubes. Used to compare to grs bubble spectra to verify
;reference pointings


l=[14.942, 17.88, 18.806, 22.635, 24.813, 25.9262, 27.5265, 27.1575, $
28.7393, 31.2067, 32.192,  37.0529, 39.8217, 39.7110, 40.3703, 43.9709, $
44.5548, 46.1367, 48.9238, 51.8709, 53.7356, 54.1181]              

b=[0.42, .60355, 0.60355, 0.855, 0.9664, -0.9155, 0.6159, -1.0139, $
0.7696, -0.8233, -0.5834, -0.8971, 0.6589, -0.9463, -0.8602, -0.3569, $
0.7881, 1.0033, 0.7696, 0.9603, -0.5527,  0.7081] 

nref=n_elements(l)
if nref ne n_elements(b) then stop
id=intarr(nref)

grs=indgen(21)*2+15
k=0
for i=0, 20, 1 do begin
    file='/users/cnb/glimpse/grs/'+strtrim(string(grs[i]),2)+'.fits'
    im=mrdfits(file,0,h,/silent)
    nx=n_elements(im[*,0,0])
    ny=n_elements(im[0,*,0])
    nz=n_elements(im[0,0,*])
    crval1=sxpar(h,'crval1')
    crval2=sxpar(h,'crval2')
    crval3=sxpar(h,'crval3')
    cdelt1=sxpar(h,'cdelt1')
    cdelt2=sxpar(h,'cdelt2')
    cdelt3=sxpar(h,'cdelt3')
    crpix1=sxpar(h,'crpix1')
    crpix2=sxpar(h,'crpix2')
    crpix3=sxpar(h,'crpix3')
;initialize spectrum array
    if i eq 0 then begin
        v=crval3+(findgen(nz)+1-crpix3)*cdelt3
        refpos=fltarr(nref+1,nz)
        refpos[0,*]=v
        k++
    endif

    ;calculate image location of ls, bs
    x=(l-crval1)/cdelt1+crpix1
    y=(b-crval2)/cdelt2+crpix2
    hit=where((x ge 0) and (x le nx-1) and (y ge 0) and (y le ny-1),ct)
    if ct ne 0 then begin
        print,file+' has '+strtrim(string(ct),2)+' reference pointings.'
        for j=0, ct-1, 1 do begin
            id[hit[j]]=grs[i]
            ;extract 7x7 pixel (2.5' by 2.5') 
            sub=im[x[hit[j]]-3:x[hit[j]]+3,y[hit[j]]-3:y[hit[j]]+3,*]
            sub=total(sub,1,/nan)
            sub=total(sub,1,/nan)/49.
            vtemp=crval3+(findgen(nz)+1-crpix3)*cdelt3
            refpos[k,*]=interpol(sub,vtemp,v)
            k++
        endfor
    endif
endfor

save,file='ref_fields.sav',l,b,refpos,id
end


