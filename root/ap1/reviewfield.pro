pro reviewfield

;review observing window selections

restore,file='jfields.sav'
ntar=n_elements(jfields[*,0])
tar=jfields[*,0]

;load bubble info table, extract bubble number from name
readcol,'/users/cnb/glimpse//glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
       ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
       ,format='a,f,f,f,f,f,f,f,f,f,a',/silent

    dx=(jfields[*,1]-l[tar-1])*3600./1.2
    dy=(jfields[*,2]-b[tar-1])*3600./1.2


for i=0,ntar-1, 1 do begin
    
    ;read bubble
    number=strtrim(string(long(tar[i])),2)
    if tar[i] lt 100 then number='0'+number
    if tar[i] lt 10 then number='0'+number
    im=file_search('/users/cnb/glimpse/irac/N'+number+'*.jpg')
    read_jpeg,im,im,true=3
    nx=n_elements(im[*,0,0])
    ny=n_elements(im[0,*,0])
    width=[jfields[i,3],jfields[i,4]]*60/1.2
    window,xsize=nx,ysize=ny,retain=2,title=number,xpos=1
    tvscl,im,true=3
    tvbox,width,nx/2.+dx[i],ny/2.+dy[i],angle=-jfields[i,5]
    wait,1
endfor
end
