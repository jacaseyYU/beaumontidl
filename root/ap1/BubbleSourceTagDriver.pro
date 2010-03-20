;+
; NAME:
;  BubbleSourceTagDriver
;
; DESCRIPTION:
;  Driver for BubbleSourceTag - runs that program on each bubble, and
;                               saves the output
;-
pro BubbleSourceTagDriver

files = file_search('/users/cnb/glimpse/pro/shells/saved/*.sav', count=ct)
if ct eq 0 then begin
    print, 'no files'
    return
endif

info = fltarr(4, ct)
for i = 0, ct -1 , 1 do begin
    print, i+1, ct, format="('Starting Shell ', i2, ' of ',i2)"
    bubble = strsplit(files[i],'/',/extract)
    bubble = strsplit(bubble[n_elements(bubble)-1],'.',/extract)
    bubble = long(bubble[0]) 
    info[0:2,i] = bubbleSourceTag(bubble)
    info[3,i] = bubble
endfor
save, info, file='info.sav'
stop
end
