;+
; NAME:
;  ysotable
;
; DESCRIPTION:
;  Turn the YSODensity file into a latex table
;-

pro ysotable

readcol, '~/paper/cat/YSODensity.txt', num, dx, dy, den, comment='#'

number = n_elements(num)

j = 1
print,'\begin{tabular}{|r | r |r |r |}'
print, '\hline'
print, 'YSO Hotspot Number & Bubble & Longitude & Latitude\\' 
print,'                &        &  (deg)    & (deg)   \\'
print,'\hline'
for i = 0, number -1, 1 do begin
    if dx[i] ge 990 then continue
    loc = getbubblepos(num[i])
    l = mean(loc[*,0]) + dx[i] / 60.
    b = mean(loc[*,1]) + dy[i] / 60.
    bub = 'N'+strtrim(floor(num[i]),2)
    print, j++, bub, l, b, $
      format = "(i2, ' & ', A5, ' & ', f7.3, ' & ', f7.3, ' \\')"
endfor

print,'\hline'
print,'\end{tabular}'
end
