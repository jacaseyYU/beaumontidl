pro grsspec

;from regions file, create spectrum of region from GRS, if covered
;overplot the given comparison field

restore,file='fields.sav'
nentry=n_elements(fields[*,0])

offloc=fltarr(nentry,3)
offloc[*,0]=findgen(nentry)

hit=where(fields[*,5] ne 0, ct)


if ct ne 0 then begin
    restore,file='ref_fields.sav'
    refl=l
    refb=b

    grscen=findgen(21)*2+15
    
    for i=0, ct-1, 1 do begin
;which reference field to use?
        l=fields[hit[i],1]
        b=fields[hit[i],2]
        refdist=(refl-l)^2+(refb-b)^2
        refbest=where(refdist eq min(refdist))
;some fields are crappy
        case refbest of
            7: ref=6
            10: ref=10
            13: ref=12
            14: ref=12
            15: ref=16
            else: ref=refbest
        endcase
        offloc[hit[i],1]=refl[ref]
        offloc[hit[i],2]=refb[ref]

;which grs image is the closest?
        r=fields[hit[i],3]/120.
        dist=abs(l-grscen)
        best=where(dist eq min(dist))
        
        if min(dist) ge 1 then begin
            print,'Bubble '+strtrim(string(hit[i]),2)+' not covered by grs'
        endif else begin ; read grs image
            file='/users/cnb/glimpse/grs/'+strtrim(string(round(grscen[best])),2)+'.fits
            im=mrdfits(file[0],0,h,/silent)        
            bad=where(~finite(im),badct)
            if badct ne 0 then im[bad]=0
            nx=n_elements(im[*,0,0])
            ny=n_elements(im[0,*,0])
            nz=n_elements(im[0,0,*])

            crval1=sxpar(h,'crval1')
            crval2=sxpar(h,'crval2')
            crval3=sxpar(h,'crval3')
            crpix1=sxpar(h,'crpix1')
            crpix2=sxpar(h,'crpix2')
            crpix3=sxpar(h,'crpix3')
            cdelt1=sxpar(h,'cdelt1')
            cdelt2=sxpar(h,'cdelt2')
            cdelt3=sxpar(h,'crpix3')
            
            xcen=(l-crval1)/cdelt1+crpix1
            ycen=(b-crval2)/cdelt2+crpix2

            ;create an aperture mask
            dist_circle,mask,[nx,ny],xcen,ycen
            in=where(mask*abs(cdelt1) le  r)
            mask=fltarr(nx,ny)
            mask[in]=1
            mask=rebin(mask,nx,ny,n_elements(im[0,0,*]))
            im*=mask
            t1=total(im,1)
            spec=total(t1,1)
            vs=crval3+(findgen(nz)-crpix3)*cdelt3
            set_plot,'ps'
            device,file=strtrim(string(hit[i]),2)+'.ps'
            spec/=float(n_elements(in));counts/pixel
            scale=max(spec)
            spec/=scale
            
            plot,vs,spec,title=strtrim(string(hit[i]),2)+' xcen: '+strtrim(string(xcen),2)+' ycen: '+strtrim(string(ycen),2)$
              ,xtitle='velocity (m/s)',xra=[vs[0],vs[nz-1]],/xsty,yrange=[-.5,2],thick=3
            oplot,refpos[0,*],refpos[ref+1,*]/scale+1.2 ;scaled to the consistent emission/solid angle
            device,/close

        endelse
    endfor

save,file='offloc.sav',offloc    
endif

set_plot,'X'
end
