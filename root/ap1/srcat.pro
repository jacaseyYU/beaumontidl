pro srcat

;*************************************************
;Create a catalog of sources to observe with JCMT
;catalog lists: (l,b) in galactic coordinates
;               dx,dy in arcseconds
;               pa in degrees
;
;UPDATE: May 2008: add columns to list:
;                  (ra,dec) in sexigessimal notation
;                  (ra,dec) of reference field
;                  distance in degrees from target and reference
;**************************************************

restore,file='fields.sav'
restore,file='offloc.sav'

hit=where(fields[*,5] ne 0, ct)
if ct ne 0 then begin

fmt='(i3," | ",2(f8.3," | "),2(f5.0," | "),f6.2," | source= ",2(i3,":",i3,":",f4.1," |  "),"ref= ",2(i3,":",i3,":",f4.1," | ")," ",f3.1)'
openw,1,'srcat.txt'

for i=0, ct-1, 1 do begin
    info=fields[hit[i],*]
    ref=offloc[hit[i],*]
    ;need to correct PA pointing- go from
    ;Galactic to Equatorial coordinates
    corr=gcrot(info[1]/!radeg,info[2]/!radeg)*!radeg
    pa=(info[5]-corr) mod 180.
    if pa le 0 then pa+=180.
    if pa ge 90 then pa-=180.

    l=info[1]
    b=info[2]
    lr=ref[1]
    br=ref[2]
    glactc,ra,dec,2000,l,b,2,/degree
    glactc,rar,decr,2000,lr,br,2,/degree
    radec,ra,dec,h,m,s,d,dm,ds
    radec,rar,decr,rh,rm,rs,rd,rdm,rds
    dist=sqrt((l-lr)^2+(b-br)^2)

    printf,1,format=fmt,info[0],l,b,info[3]*60,info[4]*60,pa,h,m,s,d,dm,ds,rh,rm,rs,rd,rdm,rds,dist
    print, format=fmt,info[0],l,b,info[3]*60,info[4]*60,pa,h,m,s,d,dm,ds,rh,rm,rs,rd,rdm,rds,dist

endfor

close,1
endif else print, 'Error: No adequate bubbles??'

end
