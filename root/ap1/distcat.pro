;+
; NAME:
;  distcat
;
; DESCRIPTION:
;  Uses bubble distances and longitudes to calculate near and far
;  kinematic distances. Writes to a file, and returns the distances
;-
pro distcat, dist

readcol, '~/paper/cat/groupCat.txt', bubble, morph, comment='#', /silent


dist = fltarr(n_elements(bubble),4)
dist[*,0]=bubble

for i=0, n_elements(bubble)-1, 1 do begin
    
    print,bubble[i]   
    bub = bubble[i]
    l = mean((getbubblepos(bub))[*,0])
    v = getbubblevel(bub)
    dist[i,1:3] = (kdisterr(l, v[0],v[1]))[[0,2,1]]

    ;- manual fixes for velcoities inconsistent with galactic rotation
    case bub of
        35:  dist[i,1:3]=[6.7,8.7,.7]
        52:  dist[i,1:3]=[6.0,8.6,1.0]
        54:  dist[i,1:3]=[6.2, 8.3, .6]
        56:  dist[i,1:3]=[6.5, 7.7, .3]
        90:  dist[i,1:3]=[5.2, 7., .4]
        92:  dist[i,1:3]=[4.8, 7.3, .8]
        130: dist[i,1:3]=[.09, 7.8, 1]
        133: dist[i,1:3]=[2.4, 5.3, 1.1]
        else:
    endcase

endfor

openw, 1, '~/paper/cat/distcat_latex.txt'
openw, 2, '~/paper/cat/distcat.txt'
printf, 1, transpose(dist), format="((i3.3, ' & ', 2(f5.1, ' & '), f5.1, ' \\'))"
printf, 2, transpose(dist), format="((i3.3, 1x, 3(f5.1, 1x)))"
close,1 
close,2


end
