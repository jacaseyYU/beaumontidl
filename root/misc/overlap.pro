pro overlap
;-read in catalogs
readcol, 'bubbles.txt', ra, dec, name, l, b, $
         ain, bin, aout, bout, ecc, rad, $
         thick, flags, skip = 34, delimiter=';', $
         format='f, f, a, f, f, f, f, f, f, f, f, f, a', /debug


readcol, 'uchii.txt', num, id, typ, lb_hii, $
         spT, bib, note, $
         skip = 17, delimiter=';', format='i, a, a, a, a, i, i'
l_hii = fltarr(n_elements(num))
b_hii = l_hii
for i = 0, n_elements(num) -1 , 1 do begin
   s = strsplit(lb_hii[i],' ',/extract)
   l_hii[i] = s[0]
   b_hii[i] = s[1]
endfor

;- find matches
for i = 0, n_elements(l_hii) -1 , 1 do begin
   if abs(b_hii[i]) gt 1 then continue
   lh = l_hii[i]
   if lh lt 10 || (lh gt 65 && lh lt 295) || lh gt 350 then continue
   d = sqrt( (l_hii[i] - l)^2 + (b_hii[i] - b)^2) / (rad / 60.)
   hit = where(d lt 1, ct)
   print, num[i], ct, format=$
          '("Source ", i3, " overlaps ", i1, " bubbles")'
endfor


end
