pro bookget

;fetch numerical recipes book from web

sec=[3,3,11,6,6,14,12,8,6,7,9,7,6,11,8,7,7,6,7,6,6]

for i=0, 20, 1 do begin
for j=0, sec[i],1 do begin
ch=strtrim(string(i),2)
s=strtrim(string(j),2)
url='curl http://www.nrbook.com/a/bookcpdf/c'+ch+'-'+s+'.pdf'
save=' > /users/cnb/glimpse/recipe/c'+ch+'-'+s+'.pdf'
string=url+save
spawn,string
endfor
endfor

end
