;- create plots of peak bubble intensity vs T, rho for RATRAN sims
; cnb 9/13/8

pro simtpplot

path='/users/cnb/ratran/bubbles/sim/'
ratio=fltarr(7,7)
copeak = fltarr(7,7)

for i=0, 48, 1 do begin
    print, 'starting '+strtrim(string(i),2)
    im1=mrdfits(path+string(i,format='(i2.2)')+'h.fits',0,h,/silent)
    im2=mrdfits(path+string(i,format='(i2.2)')+'.fits',0,h,/silent)
    im1 = total(im1[122:129,171:174,95:105])
    im2 = total(im2[122:129,171:174,95:105])
    if im2 lt .1 then stop
    ratio[i/7, (i mod 7)]= im1/im2
    copeak[i/7,(i mod 7)] = im2 / (8.*4.*11.)
endfor


window,0, xsize=800, ysize=600, retain=2, xpos=0, ypos=500
t=alog10([5,10,20,30,50,75,100])
p=alog10([5d2,1d3,2d3,5d3,1d4,2d4,5d4])
xlabel=['5','10','20','30','50','75','100']
ylabel=['5e2', '1e3', '2e3', '5e3', '1e4', '2e4', '5e4']
 
;-scale and smooth
oldt = t;
oldp = p;
ratio = congrid(ratio, 100, 100, cubic=-.5)
t = congrid(t, 100, cubic=-.5)
p = congrid(p, 100, cubic=-.5)
copeak = congrid(copeak, 100, 100,cubic=-.5)
ratio = congrid(ratio, 100, 100, cubic=-.5)

device, decomposed=0
tvlct,fsc_color('Crimson',/triple),251
tvlct,fsc_color('Blue',/triple),253
red=251
blue=253
set_plot,'ps',/interpolate
device,filename='tp.eps',/encapsulated,/color,bits_per_pixel=8, $
  xsize=11.0,ysize=8.5,xoff=0.0,yoff=11.0,/inches,/land
thk = 5
clabel = 2.0
cthk = 3.0
contour, ratio, t, p , $
  levels=[1/300., 1d-2], xrange=alog10([4,110]),yrange=alog10([4d2,6d4]),$
  /xsty,/ysty, xtitle='Log Temperature (K)', ytitle='Log H2 number density (cm^-3)', $
  charsize=2.3, charthick=5., c_annotation=['300', '100'], $
  c_charsize=clabel, c_charthick=cthk, c_thick = thk, c_color = red
contour, copeak, t, p, levels=[1, 5, 15, 30], c_annotation=['1K', '5K', $
  '15K', '30K'], /overplot, $
   c_charsize=clabel, c_charthick=cthk, c_thick=thk, c_color=blue

 oplot, rebin(oldt,7,7), rebin(1#oldp,7,7), psym=7, symsize=1
device,/close
set_plot,'X'
stop

stop
out=tvrd(/true)
write_png, '~/figures/tp.png',out 
end
