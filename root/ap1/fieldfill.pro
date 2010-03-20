pro fieldfill
;***********************
;fill in fields array
;*************************


;load bubble info table, extract bubble number from name
readcol,'/users/cnb/glimpse//glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
       ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
       ,format='a,f,f,f,f,f,f,f,f,f,a',/silent

fields=fltarr(135,6)
fields[*,0]=findgen(135)
fields[1:134,1]=l
fields[1:134,2]=b
fields[1:134,3]=a_out*3.
fields[1:134,4]=b_out*3.

restore,file='jfields.sav'

fields[jfields[*,0],*]=jfields

save,file='fields.sav',fields

end
