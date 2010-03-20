pro classifyAnalyze

restore, file='classifications.sav'
c = classifications
openw, 1, 'c.txt', width = 300
nex = n_elements(c[0,*])
natt = n_elements(c[*,0]) - 1
printf, 1, strtrim(string(nex),2) + "  " + $
       strtrim(string(natt),2)


domain = replicate('2', nflag)
domain = [domain, '5', '15']
printf, 1, domain


line = [flagNames, 'dMag', 'nmeas']

printf, 1, line

for i = 0, n_elements(c[0,*]) - 1, 1 do begin
   printf, 1, c[*,i]
endfor
close, 1


for i = 0, nflag-1, 1 do begin
   good = where(classifications[i, *] eq 1, ct)
   print,flagNames[i], ct
endfor

end



;-results

