;- Take region files, sum flux

pro regionsum

;- read velocity info
readcol,'bubblemomentmap.txt', vnum, vlo, vhi

regfile=file_search('~/analysis/reg/','???_*_?.reg',count=ct)
regnum = strarr(ct)
id = strarr(ct)
for i=0, ct-1, 1 do begin
    temp = strsplit(regfile[i],'/',/extract)
    temp = strsplit(temp[4],'_',/extract)
    regnum[i]=temp[0]
    id[i]=temp[1]
endfor
hit=uniq(regnum)
hit=[0,hit+1]
print,'num   vlo   vhi  F(int)    A(int)    F(shell)  A(shell)  F(cloud)  A(cloud)'

for i=0,n_elements(hit)-2, 1 do begin
    imfile='~/harp/bubbles/reduced/N'+regnum[hit[i]]+'.fits'
    if ~file_test(imfile) then begin
        print, 'missing image', imfile
        continue
    endif

    im=mrdfits(imfile,0,h,/silent)
    ast=nextast(h)

    ;-collapse image
    cathit = where(vnum eq fix(regnum[hit[i]]))
    if cathit[0] eq -1 then begin
        print, 'enter v info for bub'+regnum[hit[i]]
        continue
    endif

    lochan=(vhi[cathit[0]] - ast.crval[2])/ast.cd[2,2] + ast.crpix[2]-1
    hichan=(vlo[cathit[0]] - ast.crval[2])/ast.cd[2,2] + ast.crpix[2]-1
    im=total(im[*,*,lochan:hichan],3,/nan) * .2
    badmask = ~finite(im)

    ;-coord arrays
    x= rebin( (findgen(ast.sz[0]) + 1 - ast.crpix[0])*ast.cd[0,0] + ast.crval[0], ast.sz[0],ast.sz[1])
    y= rebin( 1#(findgen(ast.sz[1]) + 1 - ast.crpix[1])*ast.cd[1,1]+ast.crval[1], ast.sz[0], ast.sz[1])
    x = reform(x, ast.sz[0] * ast.sz[1])
    y = reform(y, ast.sz[0] * ast.sz[1])
    flagfield = bytarr(ast.sz[0] * ast.sz[1]) + 4B
    ;-mark flagfield
    for j=hit[i], hit[i+1]-1, 1 do begin
        readcol, regfile[j], l, b,/silent
        in=inside(x, y, l, b)
        flag = -1
        if id[j] eq 'int' then flag=1B
        if id[j] eq 'sh' then flag=2B
        if id[j] eq 'cl' then flag=3B
        if flag eq -1 then stop
        inhit = where(in eq 1, inct)
        if inct eq 0 then stop
        flagfield[inhit] = (flagfield[inhit] < flag)
    endfor 
    flagfield *= (1B - badmask)

    print, regnum[hit[i]], vlo[cathit[0]], vhi[cathit[0]], $
      total(im * (flagfield eq 1)), total(flagfield eq 1), $
      total( im * (flagfield eq 2)), total(flagfield eq 2), $
      total(im * (flagfield eq 3)), total(flagfield eq 3), $
      format="(a3, 1x, i5.3, 1x, i5.3, 6(e9.1, 1x))"
endfor

end
