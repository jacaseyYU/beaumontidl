pro allskyir

;-crawl through the glimpse image catalogs from 11-63. Tag all IR XS
;sources. Muahahahahaah!!!!

files=file_search('/users/cnb/glimpse/glimic/G*.tbl')
ct=n_elements(files)

n1=0L
n2=0L
n12=0L

for i=0, ct-1, 1 do begin
    print,files[i]
    data=readglimic(files[i])
    good=where((data.mag1 le 99) and (data.mag2 le 99) and (data.mag3 le 99) and (data.mag4 le 99))
    data=data[good]
    n1=total(((data.mag1-data.mag2) gt 0.8) or ((data.mag3-data.mag4) gt 1.1))
    n2=total(((data.mag1-data.mag2) gt 0) and ((data.mag1-data.mag2) lt 0.8) and ((data.mag3-data.mag4) gt 0.4) and ((data.mag3-data.mag4) lt 1.1))
    n12=total(((data.mag3-data.mag4) ge 1.1) and ((data.mag1-data.mag2) le .4))
    print,n1,n2,n12,format='("Class 0/I Sources: ",i5,/,"Class II Sources: ",i5,/, "Class I/II Sources: ",i5)'
endfor23123

end
