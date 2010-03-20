;- Read the bubble table, create a region file (.25 degree radius
;  circle). Call ircat on that region file


pro bubbleregion

;- get bubble info
readcol,'/users/cnb/glimpse/glimpse1_north_bubbles.txt',skipline=44,delimiter=' '$
,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
,format='a,f,f,f,f,f,f,f,f,f,a'


nbub = n_elements(l)
hit=[5,11,14,16,20,21,22,27,29,30,34,35,36,37,39,40,44,45,46,47,49,50,51,52,53,54,56,61,62,65,74,77,79,80,82,84,88,90,92,120,129,130,133]

for i=0, nbub-1, 1 do begin
    if i lt 10 then continue
    if i ge 133 then continue
    good=where(i eq hit, ct)
    if ct eq 0 then continue
    theta=findgen(100)/99.*2*!pi
    pts=[[l[i]+0.25*cos(theta)], [b[i]+0.25*sin(theta)]]
    
    file='/users/cnb/analysis/reg/aperture_'+string(i+1,format='(i3.3)')+'.reg'
    if file_test(file) then continue
    openw, 1, file
    printf,1,transpose(pts),format='(2f7.3)'
    close,1
    ircat,file
    deredden,'aperture_'+string(i+1,format='(i3.3)')+'.ircat'
endfor

end
