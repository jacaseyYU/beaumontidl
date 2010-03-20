pro reg

;generate ds9 region file

restore,file='fields.sav'
hit=where(fields[*,5] ne 0, ct)
if ct ne 0 then begin

fmt='("galactic;circle(",f6.2,"d,",f8.2,"d,",f8.2,"d) # text={",i3,"}")'
openw,1,'bubbles.reg'

for i=0, ct-1, 1 do begin
    info=fields[hit[i],*]
    printf,1,format=fmt,info[1],info[2],info[3]/120.,round(info[0])
    print,format=fmt,info[1],info[2],info[3]/120.,round(info[0])

endfor

close,1
endif else print, 'Error: No adequate bubbles??'

end
