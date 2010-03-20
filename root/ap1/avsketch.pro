;-WEIRD BIMODAL ERRORS ON K, I magnitudes
;-CHECK CATALOGS!!!

;-make some ROUGH av maps of bubbles
pro avsketch

files=file_search('/users/cnb/analysis/dered/aperture*', count=ct)
hit=intarr(ct)
for i=0, ct-1, 1 do begin
    st=strsplit(files[i],'_',/extract)
    st=strsplit(st[1],'.',/extract)
    hit[i]=floor((float(st[0])))
endfor

nfile=n_elements(hit)

for i=0, ct-1, 1 do begin
    if ~file_test('/users/cnb/glimpse/fits/i4/'+strtrim(string(hit[i]),2)+'_I4.fits') then continue

    infile='/users/cnb/analysis/dered/aperture_'+string(hit[i],format='(i3.3)')+'.dered'
    readcol,infile,l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,st,av,var
    good=where(av lt 99)
    stop
    cen = [(max(l)+min(l))/2.,(max(b)+min(b))/2.]
    wid = [0.5,0.5]
    scale = [1.,1.]*5./3600.
    npix = 360
    
    avmap=fltarr(npix,npix)*!values.f_nan
    ;-convert l, b to x, y
    x = round ( (l - cen[0]) / scale[0] + npix/2. )
    y = round ( (b - cen[1]) / scale[1] + npix/2. )
    
    left = 0 > (x-3) < (npix-1)
    right =0 >  (x +3) < (npix-1)
    bot = 0 > (y-3)  < (npix-1)
    top = 0 >  (y + 3) < (npix - 1)
        
    ;-read in IRAC FITS file
    irac=mrdfits('/users/cnb/glimpse/fits/i4/'+strtrim(string(hit[i]),2)+'_I4.fits',0,hi,/silent)
    irac=hist_equal(irac)
    irac=postagestamp(irac,hi,cen,wid,scale)

    ;-fill in avmap
    avlo = 5
    avhi = 40
    
    for j=0, n_elements(good) - 1, 1 do $
;        if av[good[j]] ge avhi then avhi=av[good[j]]
;        if av[good[j]] le avlo then avlo=av[good[j]]
        avmap[left[good[j]]:right[good[j]],bot[good[j]]:top[good[j]]] = (avlo > av[good[j]] < avhi) 
 
    nodata=where(~finite(avmap))
    indices=array_indices(avmap,nodata)
    
    avmap=bytscl(-avmap,/nan)
    avmap=rebin(avmap,npix,npix,3)
    avmap[indices[0,*]+indices[1,*]*npix]=55B
    avmap[indices[0,*]+indices[1,*]*npix+1L*npix*npix]=0B
    avmap[indices[0,*]+indices[1,*]*npix+2L*npix*npix]=0B

;-do the same for coverage
    covermap=bytarr(npix,npix)
    for j=0, n_elements(av)-1, 1 do $
      covermap[left[j]:right[j],bot[j]:top[j]]=255


    ;- display
    canvas = fltarr( 720, 720 )
    window,1,xsize= 720, ysize= 720, ypos=100, retain=2
    tvscl, avmap,true=3
    tvscl, irac, 360, 0
;    bad=where(av ge 90)
;    plots, x[bad], y[bad], psym=6, symsize=0.5,/device, color='00ff00'xl
    tvscl, covermap, 0, 360
    xs=where(st ne 3)
    plots,x[xs]+350,y[xs],/device,psym=6,symsize=0.25,color='0000ff'xl
    ;-scale bar
    bar=congrid(reform(255-indgen(255),1,255),30,350)
    tv,bar,345,0
    xyouts, 500, 340, 'Bubble '+string(hit[i]),/device,charsize=1.5,color='00ff00'xl
    for j=0, 350, 50 do begin
        val = avlo + j/350.*(avhi-avlo)
        xyouts,352,j,string(val,format='(i2)'),color='0000ff'xl, /device
    endfor
    
    out=tvrd(/true)
    write_png,'/users/cnb/figures/av_'+string(hit[i],format='(i3.3)')+'.png',out
endfor
end
