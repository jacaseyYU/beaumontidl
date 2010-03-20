pro lineprofile, bubble
;- plot line profiles from bubbles

infile=file_search('/users/cnb/analysis/reg/ln*', count=ct)

readcol, 'bubblemomentmap.txt', bubnum, vlo, vhi,/silent

for i=0, ct-1, 1 do begin
    readcol, infile[i], l, b,/silent
    
    ;- fits file
    num = strsplit(infile[i],'_',/extract)
    num = strsplit(num[1],'.',/extract)
    if float(num[0]) ne bubble then continue
    im = '/users/cnb/harp/bubbles/reduced/N'+string(num[0],format='(i3.3)')+'.fits'
    if ~file_test(im) then stop
    im = mrdfits(im, 0 , h, /silent)
    ast=nextast(h)
    
    ;- l and b to pixels
    l = (l-ast.crval[0])/ast.cd[0,0] + ast.crpix[0]-1
    b = (b-ast.crval[1])/ast.cd[1,1] + ast.crpix[1] -1
    
    ;- sum over velocities
    hit = where(bubnum eq float(num[0]), ct2)
    if ct2 eq 0 then stop
    vl = (vlo[hit] - ast.crval[2])/ast.cd[2,2] + ast.crpix[2]-1
    vh = (vhi[hit] - ast.crval[2])/ast.cd[2,2] + ast.crpix[2]-1
    im = total(im[*,*, (vl<vh) : (vl>vh)], 3)
        
    theta = atan( b[1] - b[0], l[1] - l[0])
    line = findgen(30)/29. * 2 * sqrt((b[1]-b[0])^2 + (l[1]-l[0])^2)
    linex = floor(l[0] + line*cos(theta))
    liney = floor(b[0] + line*sin(theta))

    window, 0, retain=2, xpos = 500, ypos = 600
    plot,line/max(line) * 2, im[linex,liney]

    window, 1, xsize = ast.sz[0], ysize=ast.sz[1], xpos = 0, ypos = 600, retain=2
    tvscl, im, /nan
    plots, linex, liney, color='00ff00'xl, /device
endfor
end
    
