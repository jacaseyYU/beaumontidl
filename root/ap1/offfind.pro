pro offfind

;in each grs data cube, select some regions which would make good
;offset locations

grs=indgen(21)*2+15
offpos=fltarr(2,21)
for i=0, 20, 1 do begin
    file='/users/cnb/glimpse/grs/'+strtrim(string(grs[i]),2)+'.fits'
    im=mrdfits(file,0,h)
    inf=where(~finite(im),ct)
    if ct ne 0 then im[inf]=max(im[where(finite(im))])
    nx=n_elements(im[*,0,0])
    ny=n_elements(im[0,*,0])
    nz=n_elements(finite(im[0,0,*])) ;sometimes the first or last planes are NAN. Assumed to be consistent over x,y
   
    collapse=total(im,3,/nan)
    im-=(rebin(collapse,nx,ny,nz)/nz)
    collapse=total(abs(im),3,/nan)

;sum over a ~2' box (grs pixels 20", so use 7 pixel box)
    ker=fltarr(7,7)+1
    collapse=convol(collapse,ker,/edge_truncate)

    best=sort(collapse)
    ind=array_indices(collapse,best[0])
    offpos[i]=[grs[i],ind[0],ind[1]]
    sub=im[ind[0]-3:ind[0]+3,ind[1]-3:ind[1]+3,*]
    sub=total(sub,1)
    sub=total(sub,1)
    plot,sub
    stop
endfor

end
