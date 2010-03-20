;+
; Calculate YSO source tag density for GLIMPSE catalog
;-

pro galaxysourcetag

galinfo = fltarr(53)
for i = 11, 63, 1 do begin
    print, i
    restore, file = string(i, format='(i2,".sav")')
    glimic = glimic[where(abs(glimic.b) lt 1)]
    yso = ysotag(glimic.mag1, glimic.mag2, glimic.mag3, glimic.mag4)
    galinfo[i-11] = total(yso ne 3)
endfor

save, galinfo, file='galinfo.sav'

end
