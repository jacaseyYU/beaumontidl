pro bfitdriver

;driver program for bubbelfits. Create fits images of target bubbles,
;compare side by side with the jpeg

restore,file='fields.sav'

tar=where(fields[*,5] ne 0,ntar)

for i=0,ntar-1, 1 do begin
    bubblefits,tar[i] ;use for irac
    ;grsfits,tar[i]   ;use for grs
   ; updatefield,tar[i]
endfor

end
