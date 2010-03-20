pro gpsoverplot, bubnum

im='/users/cnb/glimpse/fits/i4/'+strtrim(string(bubnum),2)+'_I4.fits'
if ~file_test(im) then begin
    print,'No Spitzer Data'
    return
endif
im=mrdfits(im,0,h,/silent)

ast=nextast(h)

bad=where(~finite(im),ct)
if ct ne 0 then im[bad]=0
im=hist_equal(im)


outsz=500
outx=ast.sz[0]>ast.sz[1]?500.:500.*ast.sz[0]/ast.sz[1]
outy=outx*ast.sz[1]/ast.sz[0]
scale=500./(ast.sz[1]>ast.sz[0])
im=congrid(im,outx,outy)

device,window_state=states
if ~states[1] then window,1,xsize=outx,ysize=outy,retain=2
tv,im

;-search for 20cm sources
cat=readgps(/diffuse)

if ast.crval[0] gt max(cat.l) or ast.crval[0] lt min(cat.l) then begin
    print,'MAGPIS doesnt cover here'
    return
endif

hit=where(((cat.l-ast.crval[0])^2+(cat.b-ast.crval[1])^2) le .5^2,ct)
if ct eq 0 then return

x=cat[hit].l
y=cat[hit].b
sz=cat[hit].boxSize/60.

x=(x-ast.crval[0])/ast.cd[0,0]+ast.crpix[0]-1
y=(y-ast.crval[1])/ast.cd[1,1]+ast.crpix[1]-1
x*=scale
y*=scale
sz*=(scale/ast.cd[1,1])

for i=0, ct-1, 1 do begin
    if (x[i] lt 0 or y[i] lt 0) then continue    
    tvbox,sz[i],x[i],y[i],color='00ff00'xl
endfor
end
