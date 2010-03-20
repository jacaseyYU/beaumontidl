pro headertest

files=file_search('/users/cnb/harp/bubbles/reduced/*.fits',count=ct)

keys=['crpix','crval']
delts=['cdelt','cd']
cds=['1_1','2_2','3_3']


for i=0, ct-1, 1 do begin
    im=mrdfits(files[i],0,h,/silent)
    for j=0, 1, 1 do begin
        for k=1, 3, 1 do begin
            if sxpar(h,keys[j]+strtrim(string(k),2)) eq 0 then $
              print, files[i]+' Missing keyword '+keys[j]+strtrim(string(k),2)
        endfor
    endfor

                                ;-check for cdelts
    for j=1,3,1 do begin
        if (sxpar(h,delts[0]+strtrim(string(j),2)) eq 0) && (sxpar(h,delts[1]+cds[j-1]) eq 0) then $
          print, files[i]+' Missing delta '+strtrim(string(j))
    endfor

endfor


end
