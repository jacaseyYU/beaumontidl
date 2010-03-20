;-make some av maps of bubbles
pro avmapdriver

files=file_search('/users/cnb/analysis/dered/aperture*', count=ct)
hit=intarr(ct)
for i=0, ct-1, 1 do begin
    st=strsplit(files[i],'_',/extract)
    st=strsplit(st[1],'.',/extract)
    hit[i]=floor((float(st[0])))
endfor

nfile=n_elements(hit)

for i=0, ct-1, 1 do begin
    if hit[i] eq 12 then continue
    if hit[i] eq 13 then continue
    if hit[i] eq 17 then continue

    infile='/users/cnb/analysis/dered/aperture_'+string(hit[i],format='(i3.3)')+'.dered'
    readcol,infile,l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,st,av,var
    good=where(av lt 99)
    avcat=transpose([[l[good]],[b[good]],[av[good]],[var[good]]])
    avmap,avcat,5/60.,header,map,/auto,sigma=3,/verbose, varmap=varmap
    
    ;-add noise to map- make it bigger
    sza=size(map)
    map=map+randomn(seed,sza[1],sza[2])*sqrt(varmap)
    maga=(350./(sza[1]>sza[2]))
    map=congrid(map,sza[1]*maga,sza[2]*maga)
    sza=size(map)
        
    ;-read in IRAC FITS file
    if ~file_test('/users/cnb/glimpse/fits/i4/'+strtrim(string(hit[i]),2)+'_I4.fits') then continue
    
    irac=mrdfits('/users/cnb/glimpse/fits/i4/'+strtrim(string(hit[i]),2)+'_I4.fits',0,hi,/silent)
    irac=hist_equal(irac)
    cen=[sxpar(header,'crval1'),sxpar(header,'crval2')]
    scale=[sxpar(header,'cdelt1'),sxpar(header,'cdelt2')] / maga
    wid=scale*sza[1:2]
    irac=postagestamp(irac,hi,cen,wid,scale)
        
    canvas=fltarr(700,350)
    
    
    window,1,xsize=700,ysize=350,retain=2,ypos=100
    tvscl, map
    tvscl, irac, 349,0,/device
    
    xyouts, 450, 320, 'Bubble '+string(hit[i],format='(i3)'),/device
    ;- color bar
    bar=congrid(reform(indgen(255),1,255),30,300)
    tv,bar,350,0,/device
    for j=0, 300, 50 do begin
        val=min(map)+j/300.*(max(map)-min(map))
        xyouts,365,j,string(val,format='(i2)'),/device,color='0000ff'xl,align=0.5
    endfor    
endfor
end
