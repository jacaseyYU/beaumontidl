pro overlap

;plot all of windows for all targets, see if we observe anything twice
restore,file='jfields.sav'
ntar=n_elements(jfields[*,0])
plot,[10,70],[-2.5,2.5],/nodata, xrange=[10,70],yrange=[-1.5,1.5],/xsty,/ysty,xtitle='Galactic Longitude', ytitle='Galactic Latitude'

for i=0,ntar-1, 1 do begin
    tvbox,[jfields[i,3]/60,jfields[i,4]/60.],jfields[i,1],jfields[i,2],color=!D.n_colors-1,/data,angle=-jfields[i,5]
endfor

end
