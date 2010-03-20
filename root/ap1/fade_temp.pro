;+
; NAME:
;  FADE
;
; DESCRIPTION:
;  This procedure creates a GUI to interact with an image and data
;  cube which overlap. Current functionality includes:
;    - Registration of cube and image, including resampling to match
;      pixel scales
;    - Ability to fade between the 2D image and a plane of the cube
;    - Ability to create and extract spectra from regions
;    - Button to display IR excess sources based on GLIMPSE data and
;      selection criteria from Megeath et al 2004
;
; CALLING SEQUENCE:
;  FADE,[bubble,/grs]
;
; OPTIONAL INPUTS:
;  bubble: Integer referincing the bubble to study. If not supplied, FADE will load bubble 36
;
; KEYWORD PARAMETERS:
;  GRS: If present and nonzero, FADE looks to load GRS data as the
;  image cube. If absent, FADE looks to load JCMT data as the cube.
;
; RESTRICTIONS:
;  As much as possible, things have been kept general so that this can
;  be adapted to other applications. However, the following parts of
;  code would likely have to be changed to adapt FADE to other tasks:
;   -Path names are specific to the bubble project. The core
;   functionality of FADE can be restored by re-coding the initial
;   data loading section. Several buttons also invoke the
;   dialog_pickfile function with specific paths defined.
;   -The following keywords are assumed to be present in the data
;   headers: crpix, cdelt, crval. The cube and image are assumed to be
;   in the same coordinate system
;   -The center of the display window is defined as the center of the
;   2D image, and the FOV of the window is fixed. The FOV can be
;   altered easily by chaning the pixel scale (via the variables dl
;   and dm). Changing the pixel size of the window would be harder, as
;   it would overflow the GUI. 
;   -Plotting IR excess sources requires running ircat on a region
;   file, which requires that the region have been surveyed by GLIMPSE
;
; KNOWN ISSUES:
;  Peakpick, the procedure to try and estimate the center and width of
;  the strongest spectral line in a region, sucks. But peakpick.pro is
;  a fun name. 
;   
; MODIFICATION HISTORY:
;  June 2008: Written by Chris Beaumont
;  July 29, 2008: Made changes to handle both CDelt and CD
;  keywords. Extract Spectrum now plots the average, not the total, flux
;-

PRO FADE_EVENT, EVENT
;get event information
widget_control,event.id,get_uvalue=widget
widget_control,event.top,get_uvalue=info,/no_copy

;adjust transparency
if widget eq 'slide' then begin
    info.slice=event.value
    render,info
    widget_control,info.velocity,set_value='Velocity: '+$
      strtrim(string(info.crval3+(info.slice-info.crpix3)*info.cdelt3),2)
endif

;-adjust slice

if widget eq 'fade' then begin
    info.alpha=(event.value/100.)
    render,info
endif

;-reset region file

if widget eq 'reset' then begin
    info.vertices=0
    render,info
endif

;- load region file

if widget eq 'load' then begin
    infile=dialog_pickfile(DEFAULT_EXTENSION='reg',/read, $
                        path='/users/cnb/analysis/reg/')
    if infile ne '' then begin
        readcol,infile,x,y,/silent

        ;-convert to image pixel coordinates

        x=(x-info.crval1)/info.cdelt1 + info.crpix1-1
        y=(y-info.crval2)/info.cdelt2 + info.crpix2-1
        info.vertices=n_elements(x)
        info.vertx[0:info.vertices-1]=x
        info.verty[0:info.vertices-1]=y
        render,info
    endif
endif

;save region file

if widget eq 'save' then begin
    x=(info.vertx+1-info.crpix1)*info.cdelt1+info.crval1
    y=(info.verty+1-info.crpix2)*info.cdelt2+info.crval2

    outfile=dialog_pickfile(DEFAULT_EXTENSION='reg',/write,/overwrite_prompt, $
                            path='/users/cnb/analysis/reg/')
    if outfile ne '' then begin
        openw,lun,outfile,/get_lun
        for i=0, info.vertices-1, 1 do begin
            printf,lun,format='(2f8.3)',x[i],y[i]
        endfor
        free_lun,lun
    endif

endif

widget_control,event.top,set_uvalue=info,/no_copy
end

;*********************************

PRO DRAW_EVENT, EVENT
;- Handle events generated inside graphics window

;get info,event structure
widget_control,event.top,get_uvalue=info,/no_copy
x=event.x
y=event.y

;right msb clicks measure length of line
if event.press eq 4 then begin
    info.xtemp=x
    info.ytemp=y
endif else if event.release eq 4 then begin
    info.xtemp=0
    info.ytemp=0
endif

widget_control,info.length,set_value=strtrim(string(sqrt((x-info.xtemp)^2.+(y-info.ytemp)^2.)),2)

;display cursor location
l=info.crval1+(event.x+1-info.crpix1)*info.cdelt1
b=info.crval2+(event.y+1-info.crpix2)*info.cdelt2
widget_control,info.position,set_value="l: "+strtrim(string(l,format='(f6.3)'),2)+"  b: "+strtrim(string(b,format='(f6.3)'),2)

;add a vertex
if event.release eq 1 then begin
    if n_elements(info.vertx) eq info.vertices then begin
        print, 'Warning: Polygon exceeded 50 points. Erasing'
        info.vertices=0
    endif

    info.vertx[info.vertices]=x
    info.verty[info.vertices]=y
    info.vertices++
    render,info
endif

widget_control,event.top,set_uvalue=info,/no_copy
end

;*********************************
PRO EXTRACT, EVENT
;- extract spectrum from the displayed region

;event structure
widget_control, event.top, get_uvalue = info, /no_copy

if info.vertices eq 0 then goto, extractend

;- conert region to sky coordinates...
x=(info.vertx)[0:info.vertices-1]
y=(info.verty)[0:info.vertices-1]
x=info.crval1+(x+1-info.crpix1)*info.cdelt1
y=info.crval2+(y+1-info.crpix2)*info.cdelt2

;- extract spectrum
mask=regionMask(info.header,x,y)
nx=sxpar(info.header,'naxis1')
ny=sxpar(info.header,'naxis2')
nz=sxpar(info.header,'naxis3')
spectrum=total(*info.rawcube*rebin(mask,nx,ny,nz)/total(mask),1)
spectrum=total(temporary(spectrum),1)

;-plot spectrum, postage stamp, zoomed spectrum
ast=nextast(info.header)
crval3=ast.crval[2]
crpix3=ast.crpix[2]
cdelt3=ast.cd[2,2];
xind=findgen(nz)

xind=crval3+(temporary(xind)+1-crpix3)*cdelt3

window,info.specid,xsize=800,ysize=400,retain=2,xpos=0,ypos=0

plot,xind,spectrum,/noerase,xtitle='Velocity',ytitle='Tantenna (K)',xra=[min(xind),max(xind)],yra=[min(spectrum),max(spectrum)],/xsty,/ysty

extractend:
widget_control,event.top,set_uvalue=info,/no_copy
end
 
;**********************************
PRO RENDER, INFO
wset,info.pixid

nx=n_elements((*info.cube)[*,0,0])
;- make the cube purple
im1=rebin((*info.cube)[*,*,info.slice],nx,nx,3)
im1[*,*,0]*=194./255.
im1[*,*,1]*=95./255.
im1[*,*,2]*=1.

;-make the 2D image orange
im2=rebin(*info.plane,nx,nx,3)
im2[*,*,0]*=246./255.
im2[*,*,1]*=127./255.
im2[*,*,2]*=41./255.

;- draw image to buffer
tv, im1*info.alpha + (1-info.alpha)*im2, true=3

for i=0,info.vertices-2, 1 do begin
    plots,info.vertx[i:i+1],info.verty[i:i+1],color='00ff00'xl,thick=2,/dev
endfor
if info.vertices ne 0 then $
  plots,info.vertx[[info.vertices-1,0]],info.verty[[info.vertices-1,0]],color='00ff00'xl,thick=2,/dev

;- copy buffer to main window
wset,info.wid
device,copy=[0,0,!D.x_size,!D.y_size,0,0,info.pixid]

end

;*********************************
pro IRPLOT,event
widget_control, event.top, get_uvalue = info, /no_copy
wset,info.wid

infile=dialog_pickfile(title='Select a catalog',path='/users/cnb/analysis/ircat')
if infile eq '' then goto, irplotend
readcol,infile,l,b,j,dj,h,dh,k,dk,i1,di1,i2,di2,i3,di3,i4,di4,tag,/silent

;-convert l, b to pixels
l=(l-info.crval1)/info.cdelt1+info.crpix1-1
b=(b-info.crval2)/info.cdelt2+info.crpix2-1

hit1=where(tag eq 1, ct1)
hit2=where(tag eq 2, ct2)
if ct1 ne 0 then plots,l[hit1],b[hit1],psym=4,color='00ff00'xl,/dev
if ct2 ne 0 then plots,l[hit2],b[hit2],psym=5,color='ff00ff'xl,/dev
xyouts,.2, .2, '0/I',color='00ff00'xl
xyouts,.4, .2, 'II',color='ff00ff'xl

widget_control,event.top,set_uvalue=info,/no_copy
irplotend:
end

;**********************************
pro fade_cleanup,tlb

widget_control,tlb,get_uvalue=info,/no_copy
if n_elements(info) eq 0 then return
ptr_free,info.cube
ptr_free,info.plane
ptr_free,info.rawcube
device,window_state=state
if state[info.specid] eq 1 then wdelete,info.specid
end
;***********************************

pro fade,bub,grs=grs

grsdir='/users/cnb/glimpse/grs/'
iracdir='/users/cnb/glimpse/fits/I4/'
jcmtdir='/users/cnb/glimpse/jcmt/'

;PASS PARAMETERS, CHECK FOR FILES, READ IMAGES
if n_params() eq 0 then bubble='36' else bubble=strtrim(string(bub),2)
if keyword_set(grs) then begin
    cubedir=grsdir
    planedir=iracdir
endif else begin
    cubedir=jcmtdir
    planedir=iracdir
endelse 

cube=cubedir+bubble+'.fits'
plane=planedir+bubble+'_I4.fits'

if ~file_test(cube) or ~file_test(plane) then begin
    message,'ERROR: Data for bubble not found',/continue
    goto, theend
endif

cube=mrdfits(cube,0,h1,/silent)
plane=mrdfits(plane,0,h2,/silent)

;SCALE INTENSITIES

inf=where(~finite(cube),ct)
if ct ne 0 then begin
    if ct lt n_elements(cube) then begin
        cube[inf]=min(cube[where(finite(cube))])
    endif else begin
        message, 'ERROR: Cube has no finite pixel values',/continue
        goto,theend
    endelse
endif  
       
inf=where(~finite(plane),ct)
if ct ne 0 then begin
    if ct lt n_elements(plane) then begin
        plane[inf]=min(plane[where(finite(plane))])
    endif else message, 'ERROR: Plane has no finite pixel values'
endif

;store the raw data cube
rawcube=cube

cube=bytscl(sigrange(cube,fraction=.995),/nan)
plane=bytscl(sigrange(plane,fraction=.995),/nan)

;REGRID IMAGES
;viewing window is a 500x500 pixel square centered on plane's center
;pixel size=1.8"
;coordinate conventions:
;(x,y)   - raw plane pixel image
;(u,v,w) - raw cube pixel image
;(l,m,n) - display (regridded) pixel images (cube or plane)

;-cube and plane headers in structure form
ch=nextast(h1)
ph=nextast(h2)


v1c=ch.crval[0]
v2c=ch.crval[1];sxpar(h1,'crval2')
d1c=ch.cd[0,0];sxpar(h1,'cdelt1')
d2c=ch.cd[1,1];sxpar(h1,'cdelt2')
p1c=ch.crpix[0];sxpar(h1,'crpix1')
p2c=ch.crpix[1];sxpar(h1,'crpix2')
v1p=ph.crval[0];sxpar(h2,'crval1')
v2p=ph.crval[1];sxpar(h2,'crval2')
d1p=ph.cd[0,0];sxpar(h2,'cdelt1')
d2p=ph.cd[1,1];sxpar(h2,'cdelt2')
p1p=ph.crpix[0];sxpar(h2,'crpix1')
p2p=ph.crpix[1];sxpar(h2,'crpix2')
crval3=ch.crval[2];sxpar(h1,'crval3')
crpix3=ch.crpix[2];sxpar(h1,'crpix3')
cdelt3=ch.cd[2,2];sxpar(h1,'cdelt3')

nx=n_elements(plane[*,0])
ny=n_elements(plane[0,*])
nu=n_elements(cube[*,0,0])
nv=n_elements(cube[0,*,0])
nw=n_elements(cube[0,0,*])
sz=501L
nl=sz
nm=sz
nn=nw<600
dl=-5e-4
dm=5e-4

lcen=v1p+(nx/2.+1-p1p)*d1p
mcen=v2p+(ny/2.+1-p2p)*d2p

plane=subim(plane,h2,[v1p,v2p],[nl,nm],[.25,.25])
cube=subim(cube,h1,[v1p,v2p,crval3],[nl,nm,nn],[.25,.25,nw*abs(cdelt3)])

goto, next
;make a black border
cube[0,*,*]=0
cube[nu-1,*,*]=0
cube[*,0,*]=0
cube[*,nv-1,*]=0
plane[0,*]=0
plane[nx-1,*]=0
plane[*,0]=0
plane[*,ny-1]=0

;pixel coordinates of draw window... 
lpix=lindgen(sz*sz) mod sz
mpix=lindgen(sz*sz)/ sz

;...to sky coordinates...
lpix=lcen+(temporary(lpix)-sz/2)*dl
mpix=mcen+(temporary(mpix)-sz/2)*dm

;...to coordinates of cube
upix=fix(0>round((lpix-v1c)/d1c+p1c-1)<nu-1)
vpix=fix(0>round((mpix-v2c)/d2c+p2c-1)<nv-1)

;...to coordinates of plane
xpix=fix(0>round((lpix-v1p)/d1p+p1p-1)<nx-1)
ypix=fix(0>round((mpix-v2p)/d2p+p2p-1)<ny-1)

;some playing around shows that looping 
;executes the fastest, with minimal memory overhead

newim=bytarr(nl,nm,nn)
upix=reform(temporary(upix),nl,nm)
vpix=reform(temporary(vpix),nl,nm)
wpix=intarr(nl*nm)

for i=0,nn-1,1 do begin
    newim[0,0,i]=cube[upix,vpix,wpix+fix(i*float(nw)/float(nn))]
endfor
cube=temporary(newim)

;repeat for plane
xpix=reform(temporary(xpix),nl,nm)
ypix=reform(temporary(ypix),nl,nm)
plane=temporary(plane[xpix,ypix])
next:

;Astrometry parameters for output image
crval1=lcen
crpix1=nl/2.
cdelt1=dl
crval2=mcen
crpix2=nm/2.
cdelt2=dm
crval3=crval3+(1-crpix3)*cdelt3
crpix3=1
cdelt3=cdelt3*float(nw)/nn

;scale images

;create gui
tlb=widget_base(row=1,xsize=1.5*sz,ysize=sz,title='~~FADE~~   Bubble: '+bubble)
left=widget_base(tlb,xsize=sz,ysize=sz)

win=widget_draw(left,xsize=sz,ysize=sz,retain=2,/button_events,/motion_events,uvalue='draw',event_pro='draw_event')

right=widget_base(tlb,/column,xsize=.5*sz,ysize=sz)
slider=widget_slider(right,/drag,xsize=.5*sz,uvalue='slide',title='Velicty Channel',value=(nn-1)/2,max=nn-1)
fader=widget_slider(right,/drag,xsize=.5*sz,uvalue='fade',title='Plane <------------------------> Cube',value=50,max=100)
label=widget_label(right,value='Velocity: ',xsize=.5*sz,/align_left);
label2=widget_label(right,value='l:   b:   ',xsize=.5*sz,/align_left)

regbase=widget_base(right,row=3,xsize=.5*sz)
load=widget_button(regbase,value='Load Region', uvalue='load',/align_left)
reset=widget_button(regbase,value='Erase Region',uvalue='reset',/align_left)
save=widget_button(regbase,value='Save region', uvalue='save',/align_left)
extract=widget_button(regbase,value='Extract Spectrum',event_pro='extract',/align_left)
irplot=widget_button(regbase,value='Plot IR sources', /align_left,event_pro='irplot')
length=widget_label(right,value=' ',xsize=.5*sz,/align_left,uvalue='length')

widget_control,tlb,/realize

window,xsize=sz,ysize=sz,/pixmap,/free
pixid=!d.window

device,window_state=used
good=where(used eq 0,ct)
if ct eq 0 or min(good) ge 32 then message,'Error- too many windows open'
specid=min(good)

widget_control,win,get_value=wid
wset,wid


;draw the initial window: central cube plane, 50% transparency
;tv,cube[*,*,nn/2]*.5+.5*plane


info={cube:ptr_new(cube,/no_copy), $
      slice:(nn-1)/2,$
      alpha:.5,$
      plane:ptr_new(plane,/no_copy),$
      rawcube:ptr_new(rawcube,/no_copy), $ ; raw data cube
      header:h1, $   ; raw cube header
      wid:wid,$
      pixid:pixid,$
      specid:specid, $
      crval1:crval1,$
      crpix1:crpix1,$
      cdelt1:cdelt1,$
      crval2:crval2,$
      crpix2:crpix2,$
      cdelt2:cdelt2,$
      crpix3:crpix3,$
      crval3:crval3,$
      cdelt3:cdelt3,$
      velocity:label, $
      position:label2,$
      length:length, $
      vertices:0, $
      xtemp:0, $
      ytemp:0, $
      vertx:fltarr(50), $
      verty:fltarr(50)}
widget_control,label,set_value='velocity: '+strtrim(string(crval3+((nn-1)/2-crpix3)*cdelt3),2)

render,info
widget_control,tlb,set_uvalue=info,/no_copy
xmanager,'fade',tlb,cleanup='fade_cleanup',/no_block
theend:
end
