;+
; NAME:
;  bubbleCorrelations
;
; DESCRIPTION:
;  Explore the relationship between YSO density, morphology, group ID
;-
pro bubbleCorrelations

;readcol, '~/paper/cat/vByEye.txt', bub, vlo, vhi, comment='#'
readcol, '~/paper/cat/groupCat.txt', grpBub, grpID, comment='#', /silent
readcol, '~/paper/cat/YSOdensity.txt', YSOBub, x, y, den, comment='#', /silent

if max(grpBub ne YSOBub) eq 1 then stop
;-get distances
dist = fltarr(43)
for i = 0, 42, 1 do begin
    dist[i] = (getBubbledist(grpBub[i]))[0]
endfor

;-plot YSO surf dens as a function of dis- hope for no correlation
good   = den le 990
single = where(good and grpID eq 0)
comp   = where(good and grpID eq 1)
coll   = where(good and grpID eq 2)

h1 = histogram(den[single], binsize = 1, loc = loc1)
h2 = histogram(den[comp], binsi = 1, loc = loc2)
h3 = histogram(den[coll], binsi = 1, loc = loc3)
xra = minmax([loc1,loc2,loc3])+[-1,1]
yra = minmax([h1,h2,h3])+[0,1]
plot, loc1, h1, psym = 10, xra = xra, yra = yra, /xsty,/ysty
oplot, loc2, h2, psym = 10, color = fsc_color('crimson')
oplot, loc3, h3, psym = 10, color = fsc_color('blue')

kstwo, den[single], den[comp], d1, p1
kstwo, den[single], den[coll], d2, p2
kstwo, den[comp], den[coll], d3, p3

print, p1, p2, p3

stop
end
