pro updateoff, bubble

;**********************************************************
;interactively determine the offset field for bubble
;
;if available, try using GRS cubes. If not, use SFD
;maps from skyview
;
;**********************************************************

;load bubble info table, extract bubble number from name
readcol,'/users/cnb/glimpse//glimpse1_north_bubbles.txt',skipline=44,delimiter=' ' $
       ,num,l,b,a_in,b_in,a_out,b_out,e,r,dr,flags $
       ,format='a,f,f,f,f,f,f,f,f,f,a',/silent

restore,file='fields.sav'
width=reform(fields[bubble,3:4]*60/1.2)
rot=fields[bubble,5]
xcen=fields[bubble,1]
ycen=fields[bubble,2]

                                ;read bubble
grsims=findgen(21)*2+15

number=strtrim(string(bubble),2)
im=mrdfits('/users/cnb/glimpse/fits/'+number+'.fits',0,head,/silent)
im=alog(im+1)
nx=n_elements(im[*,0])
ny=n_elements(im[0,*])

cdelt1=sxpar(head,'cdelt1')
cdelt2=sxpar(head,'cdelt2')
crpix1=sxpar(head,'crpix1')
crpix2=sxpar(head,'crpix2')
crval1=sxpar(head,'crval1')
crval2=sxpar(head,'crval2')

dx=(xcen-crval1)/cdelt1
dy=(ycen-crval2)/cdelt2

window,0,xsi=nx,ysi=ny,retain=2,xpos=1.,title=number
tvscl,im
done=0

while ~done do begin
                                ;get window properties
    rot=atan(y-.5,x-.5)*!radeg
    tvbox,width,nx/2.+dx,ny/2.+dy,0,thick=3,color=!D.n_colors-1,angle=-rot
    
    read,'1:PA  2:a_up 3:a_down  4:b_up  5:b_down  6:dx+  7: dx-  8:dy+  9:dy- 10:accept 11:abort', decision
    
    case decision of
        1:cursor,x,y,/down
        2:width[0]+=.1*fields[bubble,3]*60/1.2
        3:width[0]-=.1*fields[bubble,3]*60/1.2
        4:width[1]+=.1*fields[bubble,4]*60/1.2
        5:width[1]-=.1*fields[bubble,4]*60/1.2
        6:dx+=10
        7:dx-=10
        8:dy+=10
        9:dy-=10
        10:done=1
        11:goto,theend
        else: print,'Not a valid selection'
    endcase
    tvscl,im
endwhile    

lon=crval1+cdelt1*dx
lat=crval2+cdelt2*dy
fields[bubble,*]=[bubble,lon,lat,width[0]*1.2/60,width[1]*1.2/60,rot]
save,file='fields.sav',fields


theend:
end
