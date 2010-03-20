function subim, im, h, cen, wid, area
;-regrid a 2d image or 3d data cube


;-cen center in sky coordinates
;-wid width in pixels
;-area area in sky coordinates

sz=size(im)
ndim=sz[0]
if (ndim lt 2) or (ndim gt 3) then message,'Input image must be 2 or 3 dimensional'

if (n_elements(wid) ne ndim) or (n_elements(area) ne ndim) or (n_elements(cen) ne ndim) then $
 message,'Input and output image must have the same dimenions'


;-generate reference sky coordinates
l = ( findgen(wid[0])-(wid[0]-1)/2. ) * area[0]/wid[0] + cen[0]
m = ( findgen(wid[1])-(wid[1]-1)/2. ) * area[1]/wid[1] + cen[1]
if (ndim eq 3) then $
n = ( findgen(wid[2])-(wid[2]-1)/2. ) * area[2]/wid[2] + cen[2]


;-convert this to pixel coordinates
l=reform( rebin( l, wid[0], wid[1]), wid[0]*wid[1] )
m=reform( rebin( reform( m, 1, wid[1] ),wid[0], wid[1] ), wid[0]*wid[1] )

coords=sky2pix( h,transpose([[l],[m]]) )

x=0 > reform(coords[0,*],wid[0],wid[1]) < (sz[1]-1)
y=0 > reform(coords[1,*],wid[0],wid[1]) < (sz[1]-1)


if (ndim eq 2) then $
  return,im[x,y] $
else begin
    h=nextast(h)
    n=0 > ( (n-cen[2])/h.cdelt[2,2]+h.crpix[2]-1 ) < (sz[2] - 1)
    result=fltarr(wid[0],wid[1],wid[2])
    for i=0, wid[2]-1, 1 do begin
        result[*,*,i]=im[x,y,n[i]]
    endfor
    return, result
endelse

end

 
