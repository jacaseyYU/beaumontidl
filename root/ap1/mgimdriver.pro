pro mgimdriver, bubnum=bubnum
readcol,'bubblemomentmap.txt',bubbles,lowv,highv


nbub=n_elements(bubbles)
for i=0,nbub-1, 1 do begin
    if bubbles[i] eq 16 then continue
    if bubbles[i] eq 39 then continue
    if bubbles[i] eq 49 then continue
;    if bubbles[i] eq 65 then continue
    if bubbles[i] eq 90 then continue
    if bubbles[i] eq 46 then continue
    if keyword_set(bubnum) && bubbles[i] ne bubnum then continue
    jcmt='/users/cnb/harp/bubbles/reduced/N'+string(bubbles[i],format='(i3.3)')+'.fits'
    irac='/users/cnb/glimpse/fits/I4/'+strtrim(string(round(bubbles[i])),2)+'_I4.fits'
    jcmt=mrdfits(jcmt,0,hj,/silent)
    irac=mrdfits(irac,0,hi,/silent)
    ;-construct viewing windo information
    ast=nextast(hi)
    cen=fltarr(3)
    cen[0:1]=ast.crval
    cen[2]=(lowv[i]+highv[i])/2.
    wid=fltarr(3)
;    wid[0:1]=ast.cd[1,1]*(ast.sz[0]>ast.sz[1])
    wid[0:1]=[.25,.25]
    wid[2]=abs(highv[i]-lowv[i])
    scale=[ast.cd[0,0],ast.cd[1,1],0.2]
    jout=postagestamp(jcmt,hj,cen,wid,scale)
    iout=postagestamp(irac,hi,cen[0:1],wid[0:1],scale[0:1])
    print,lowv[i],highv[i]
    mgim3,jout,iout,lowv[i],highv[i],scale[1],string(bubbles[i],format='(i3.3)')
endfor
end
