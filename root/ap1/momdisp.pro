pro momdisp_event, event

widget_control,event.id,get_uvalue=widget
widget_control,event.top,get_uvalue=info,/no_copy

if widget eq 'glo' then info.bcut[0]=event.value
if widget eq 'ghi' then info.bcut[1]=event.value
if widget eq 'clo' then info.ccut[0]=event.value
if widget eq 'chi' then info.ccut[1]=event.value

if widget eq 'save' then begin
    out=tvrd(true=1)
    write_png,info.outname,out
endif

render,info

widget_control,event.top,set_uvalue=info,/no_copy
end


pro render, info

glo=info.glo+(info.ghi-info.glo)/500.*info.bcut[0]
ghi=info.glo+(info.ghi-info.glo)/500.*info.bcut[1]
clo=info.clo+(info.chi-info.clo)/500.*info.ccut[0]
chi=info.clo+(info.chi-info.clo)/500.*info.ccut[1]

;- scale images
c=0 > 255.*(*info.color-clo)/(chi-clo) < 255
bw=0. > 1.0*(*info.bw-glo)/(ghi-glo) < 1.

bad=where(~finite(c),ct)
if ct ne 0 then c[bad]=0

;-input/output size information
sz=size(*info.color)
outsize=500.
imx=round((sz[1] gt sz[2])?outsize:sz[1]/sz[2]*outsize)
imy=round((sz[1] gt sz[2])?outsize:sz[2]/sz[1]*outsize)
barx=imx
bary=imy/10
borderx=50
bordery=50
gapy=30
szx=imx+borderx
szy=imy+bordery+gapy+bary

im=fltarr(sz[1],sz[2],3)
im[*,*,0]=(0.6*info.r[c]+0.4*255.)*bw
im[*,*,1]=(0.6*info.g[c]+0.4*255.)*bw
im[*,*,2]=(0.6*info.b[c]+0.4*255.)*bw

bad=where(~finite(im),ct)
if ct ne 0 then im[bad]=0

;-regrid output image to desired size
im=congrid(im,imx,imy,3,cubic=-0.5)
erase
tv,im,borderx/2.,bordery/2.,true=3

;-color bar

barind=findgen(barx)
barind=rebin(bytscl(barind),barx,bary)
bar=bytarr(barx,bary,3)
bar[*,*,0]=info.r[barind]
bar[*,*,1]=info.g[barind]
bar[*,*,2]=info.b[barind]
tv,bar,borderx/2,bordery/2+imy+gapy,true=3
;-annotate the colorbar
;xyouts,(borderx+imx)/2,3./4*bordery+gapy+bary+imy,'(km/s)',/device,alignment=0.5
nticks=7
left=borderx/2
right=imx+borderx/2
bot=bordery/2+gapy+imy
top=bot+bary
plots,[left,right,right,left,left],[bot,bot,top,top,bot],/device
for i=0,nticks-1,1 do begin
    plots,(left+barx/(nticks-1.)*i)*[1,1],[bot,bot+bary/10],/device
    if (i eq 0) then a=0 else if (i eq nticks-1) then a=1 else a=0.5
    xyouts,left+barx/(nticks-1.)*i,bot-gapy/2,strtrim(string(clo+(chi-clo)/(nticks-1.)*i,format='(f5.1)'),2),/device,alignment=a
endfor

end

pro momdisp, bw, color, outname,ct=ct,clo=clo,chi=chi

if ~keyword_set(ct) then ct=34
;-load a color table and get the RGB colors
loadct,ct,/silent
tvlct,r,g,b,/get

sz=size(color)
outsize=500.
imx=round((sz[1] gt sz[2])?outsize:sz[1]/sz[2]*outsize)
imy=round((sz[1] gt sz[2])?outsize:sz[2]/sz[1]*outsize)
barx=imx
bary=imy/10
borderx=50
bordery=50
gapy=30
szx=imx+borderx
szy=imy+bordery+gapy+bary

window,0,xsize=szx,ysize=szy,retain=2,ypos=100


;clo=min(color,max=chi,/nan)
;glo=min(bw,max=ghi,/nan)
;clo=-20.
;chi=140.
glo=0.
ghi=50.

info={color:ptr_new(color,/no_copy),$
      bw:ptr_new(bw,/no_copy),$
      glo:glo,$
      ghi:ghi,$
      clo:clo,$
      chi:chi,$
      r:r, g:g, b:b,$
      bcut:[0.,500.], ccut:[0.,500.],$
      outname:outname}

;-make the control widget
tlb=widget_base(column=1,xsize=400)

s1=widget_slider(tlb,uvalue='glo',value=0,minimum=0,maximum=500,xsize=600,title='Black')
s2=widget_slider(tlb,uvalue='ghi',value=500,minimum=0,maximum=500,xsize=600,title='White')
s3=widget_slider(tlb,uvalue='clo',value=0,minimum=0,maximum=500,xsize=600,title='Low Color')
s4=widget_slider(tlb,uvalue='chi',value=500,minimum=0,maximum=500,xsize=600,title='Hi Color')
s5=widget_button(tlb,uvalue='save',value='Save')
render,info

widget_control,tlb,/realize
widget_control,tlb,set_uvalue=info,/no_copy

xmanager,'momdisp',tlb

end
