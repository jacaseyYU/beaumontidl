pro pickfield
;******************************************************
;interactively determine the JCMT observing window of selected bubbles
;start with estimates from the catalog, and update from there
;
;*****************************************************


;bubbles to focus on
tar=[3,4,5,10,11,14,15,16,20,21,22,27,29,30,34,35,36,37,39,40,44,45,46,47,49,$
50,51,52,53,54,56,61,62,65,74,77,79,80,82,84,88,90,91,92,94,95,98,101,102,108,$
111,114,115,117,120,123,124,126,127,128,129,130,133]
ntar=n_elements(tar)

;display bubble images, get user prompt
for i=0,ntar-1, 1 do begin
    updatefield,tar[i]
endfor     

end
