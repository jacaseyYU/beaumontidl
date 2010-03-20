pro glmicfetch

;num=[17,22,25,27,31,32,37,39,41,43,44,47,49,52]
num=indgen(53)+11
for i=0, n_elements(num)-1, 1 do begin
    test=file_test('/users/cnb/glimpse/glimic/GLIMIC_l0'+strtrim(string(num[i]),2)+'.tbl*')
    if test then continue
    str="curl http://data.spitzer.caltech.edu/popular/glimpse/20070416"+$
      "_enhanced_v2/source_lists/north/GLMIC_l0"+strtrim(string(num[i]),2)+$
      ".tbl.gz > /users/cnb/glimpse/glimic/GLIMIC_l0"+strtrim(string(num[i]),2)+$
      ".tbl.gz"
    
    spawn,str
;print,str
    
endfor

end
