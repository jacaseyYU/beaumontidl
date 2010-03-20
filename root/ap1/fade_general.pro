;+
; NAME:
;   FADE
;
; PURPOSE:
;   This procedure creates a gui to perform a quick comparison
;   between an image cube and single image of the same region.
;   This can be used, for example, to correlate emission
;   structures in radio data cubes with structures in optical images.
;
; CALLING SEQUENCE:
;   FADE, cube=cube, plane=plane
;
; KEYWORD PARAMETERS:
;   cube:  String referencing the filename of the cube. A
;   dialog_pickfile window is presented if this keyword is not present.
;
;   plane: String referencing the filename of the single image. A
;   dialog_pickfile window is presented if this keyword is not present.
;
;
; RESTRICTIONS:
;   -Both images must be fits files with valid headers.
;   -The images must share a common coordinate system, or the
;   registration will not be performed correctly. The program doesn't
;   check for this!
;   -Currently, the output window and pixel scales are fixed (500
;   pixels at 1.8"/pixel)
;
; MODIFICATION HISTORY:
;   Written by: Chris Beaumont, June 2008
;-

pro fade_event,event

;get info structure

widget_control,event.id,get_uvalue=widget
widget_control,event.top,get_uvalue=info,/no_copy

if widget eq 'slide' then info.slice=event.value
if widget eq 'fade' then info.alpha=(event.value/100.)

wset,info.pixid
tv,(*info.cube)[*,*,info.slice]*info.alpha+(1-info.alpha)*(*info.plane)
wset,info.wid
device,copy=[0,0,!D.x_size,!D.y_size,0,0,info.pixid]
widget_control,info.velocity,set_value='Velocity: '+strtrim(string(info.crval3+(info.slice-info.crpix3)*info.cdelt3),2)
widget_control,event.top,set_uvalue=info,/no_copy
end

;********************************************

pro fade_cleanup,tlb
widget_control,tlb,get_uvalue=info,/no_copy
if n_elements(info) eq 0 then return
ptr_free,info.cube
ptr_free,info.plane
end

;********************************************

pro fade, cube=cube, plane=plane

;PASS PARAMETERS, CHECK FOR FILES, READ IMAGES
if ~keyword_set(cube) then cube=dialog_pickfile(title='Select a Data Cube',filter='*.fits')
test=file_test(cube)
if ~test then begin
    message,'Cube file not found',/continue 
    goto,theend
endif


if ~keyword_set(plane) then plane=dialog_pickfile(title='Select an Image',filter='*.fits')
test=file_test(plane)
if ~test then begin
    message,'Image file not found',/continue 
    goto,theend
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

cube=bytscl(sigrange(cube,fraction=.97),/nan)
plane=bytscl(sigrange(plane,fraction=.97),/nan)

;REGRID IMAGES
;viewing window is a 500x500 pixel square centered on plane center
;pixel size=1.8"
;coordinate conventions:
;(x,y)   - raw plane pixel image
;(u,v,w) - raw cube pixel image
;(l,m,n) - display (regridded) pixel images (cube or plane)

v1c=sxpar(h1,'crval1')
v2c=sxpar(h1,'crval2')
d1c=sxpar(h1,'cdelt1')
d2c=sxpar(h1,'cdelt2')
p1c=sxpar(h1,'crpix1')
p2c=sxpar(h1,'crpix2')
v1p=sxpar(h2,'crval1')
v2p=sxpar(h2,'crval2')
d1p=sxpar(h2,'cdelt1')
d2p=sxpar(h2,'cdelt2')
p1p=sxpar(h2,'crpix1')
p2p=sxpar(h2,'crpix2')
crval3=sxpar(h1,'crval3')
crpix3=sxpar(h1,'crpix3')
cdelt3=sxpar(h1,'cdelt3')

nx=n_elements(plane[*,0])
ny=n_elements(plane[0,*])
nu=n_elements(cube[*,0,0])
nv=n_elements(cube[0,*,0])
nw=n_elements(cube[0,0,*])
sz=500L
nl=sz
nm=sz
nn=nw<400

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
lcen=v1p+(nx/2.-p1p)*d1p
mcen=v2p+(ny/2.-p2p)*d2p
lpix=lcen+(temporary(lpix)-sz/2)*(-5e-4)
mpix=mcen+(temporary(mpix)-sz/2)*(5e-4)

;...to coordinates of cube
upix=fix(0>round((lpix-v1c)/d1c+p1c)<nu-1)
vpix=fix(0>round((mpix-v2c)/d2c+p2c)<nv-1)

;...to coordinates of plane
xpix=fix(0>round((lpix-v1p)/d1p+p1p)<nx-1)
ypix=fix(0>round((mpix-v2p)/d2p+p2p)<ny-1)

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

;update 3rd dimension header parameters
crval3=crval3+(1-crpix3)*cdelt3
crpix3=1
cdelt3=cdelt3*float(nw)/nn

;scale images

;create gui
tlb=widget_base(row=1,xsize=1.5*sz,ysize=sz,title='~~FADE~~')
left=widget_base(tlb,xsize=sz,ysize=sz)

win=widget_draw(left,xsize=sz,ysize=sz)

right=widget_base(tlb,/column,xsize=.5*sz,ysize=sz)
slider=widget_slider(right,/drag,xsize=.5*sz,uvalue='slide',title='Velicty Channel',value=(nn-1)/2,max=nn-1)
fader=widget_slider(right,/drag,xsize=.5*sz,uvalue='fade',title='Plane <------------------------> Cube',value=50,max=100)
label=widget_label(right,value='Velocity: ',xsize=.5*sz,/align_left);

widget_control,tlb,/realize

window,xsize=sz,ysize=sz,/pixmap,/free
pixid=!d.window
widget_control,win,get_value=wid
wset,wid

;draw the initial window: central cube plane, 50% transparency
tv,cube[*,*,nn/2]*.5+.5*plane

info={cube:ptr_new(cube,/no_copy), slice:(nn-1)/2, alpha:.5, plane:ptr_new(plane,/no_copy),wid:wid,pixid:pixid,$
crpix3:crpix3,crval3:crval3,cdelt3:cdelt3,velocity:label}
widget_control,label,set_value='velocity: '+strtrim(string(crval3+((nn-1)/2-crpix3)*cdelt3),2)
widget_control,tlb,set_uvalue=info,/no_copy

xmanager,'fade',tlb,cleanup='fade_cleanup',/no_block
theend:
end
