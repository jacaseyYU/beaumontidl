pro bubbles

;********************
;old program to download 2mass or iras images


; read Churchwell Tables 2 and 3 and select bubbles
; based on position and size


readcol,'churchwell/glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
       ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
       ,format='a,f,f,f,f,f,f,f,f,f,a'

euler,l,b,ra,dec,select=2
ra=ra/15.


;plot,ra,dec $
;    ,xra=[18,20],xsty=1 $
;    ,yra=[-30,40],ysty=1 $
;    ,/nodata
;oplot,ra,dec,psym=7

;decmin=-20.
;decmax=90.
rmin=2.0
rmax=60.0
lmin=18.
lmax=52.

good=where(l gt lmin and l lt lmax $
       and r gt rmin and r lt rmax $
          ,ngood)
if(ngood eq 0) then begin
  print,"No good!"
  return
endif else print,format='("--------",i3," bubbles found --------")',ngood

for n=0,ngood-1 do begin
  i=good(n)
;  print,format='(a4,3x,i2,x,i2,x,f4.1,3x,i3,x,i2,x,f4.1,3x,f6.3,3x,f6.3,3x,f4.1)', $
 ;                num(i),sixty(ra(i)),sixty(dec(i)),l(i),b(i),r(i)

;query skyview website download IRAS 60 micron data
string='curl "http://skyview.gsfc.nasa.gov/cgi-bin/images?Survey=2MASSH&position='$
+strtrim(string(l(i)),2)+','+strtrim(string(b(i)),2)+'&size=1.0,1.0&'$
+'coordinates=GALACTIC&pixels=600&return=FITS" >'$
+'2MASS/'+num(i)+'.FITS'

spawn,string

endfor






return
end
