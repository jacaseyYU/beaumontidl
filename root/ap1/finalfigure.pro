pro finalfigure

dir='/users/cnb/figures/'
file1=dir+'10_pretty.png'
file2=dir+'22_pretty.png'
file3=dir+'29_pretty.png'
file4=dir+'45_pretty.png'


read_png,file3,im1
read_png,file2,im2
read_png,file1,im3
read_png,file4,im4

;-manual trimming
im2=im2[*,*,20:331]

;-determine mag for each image
sz1=size(im1)
sz2=size(im2)
sz3=size(im3)
sz4=size(im4)

mag1=500./(sz1[2]>sz1[3])
mag2=500./(sz2[2]>sz2[3])
mag3=500./(sz3[2]>sz3[3])
mag4=500./(sz4[2]>sz4[3])


sz1[2:3]=floor(sz1[2:3]*mag1)
sz2[2:3]=floor(sz2[2:3]*mag2)
sz3[2:3]=floor(sz3[2:3]*mag3)
sz4[2:3]=floor(sz4[2:3]*mag4)

;-resize each image
im1=congrid(im1,3,sz1[2],sz1[3],cubic=-0.5)
im2=congrid(im2,3,sz2[2],sz2[3],cubic=-0.5)
im3=congrid(im3,3,sz3[2],sz3[3],cubic=-0.5)
im4=congrid(im4,3,sz4[2],sz4[3],cubic=-0.5)

;-add a 2-arcmin bar to each image

im1[*,20:(20+99*mag1),20:25]=255
im2[*,20:(20+99*mag2),20:25]=255
im3[*,20:(20+99*mag3),20:25]=255
im4[*,20:(20+99*mag4),20:25]=255


;-find offsets for each image
o1=(500-sz1[2:3])/2.+[15,15]
o2=(500-sz2[2:3])/2.+[499,0]+[15,15]
o3=(500-sz3[2:3])/2.+[0,499]+[15,15]
o4=(500-sz4[2:3])/2.+[499,499]+[15,15]

;make final image

finalim=bytarr(3,1030,1030)+175

finalim[*,o1[0]:o1[0]+sz1[2]-1,o1[1]:o1[1]+sz1[3]-1]=im1
finalim[*,o2[0]:o2[0]+sz2[2]-1,o2[1]:o2[1]+sz2[3]-1]=im2
finalim[*,o3[0]:o3[0]+sz3[2]-1,o3[1]:o3[1]+sz3[3]-1]=im3
finalim[*,o4[0]:o4[0]+sz4[2]-1,o4[1]:o4[1]+sz4[3]-1]=im4

;finalim[*,0:999,498:501]=0
;finalim[*,498:501,0:999]=0

;window,1,xsize=1030,ysize=1030,retain=2,xpos=0

;tv,finalim,/true
write_png,'figure2.png',bytscl(finalim)

;-make a transparent version
finalim2=bytarr(4,1030,1030)
finalim2[0:2,*,*]=finalim
finalim2[3,*,*]=255*(1-((finalim[0,*,*] eq 175) and (finalim[1,*,*] eq 175) and (finalim[2,*,*] eq 175)))
write_png,'figure2_transparent.png',bytscl(finalim2)

;-figure 1

dops=['36_doppler_clean.png','36_doppler_thresh_020.png','36_doppler_thresh_030.png','36_doppler_thresh_050.png','36_doppler_triplet.png']

for i=0, 4, 1 do begin
    read_png,'/users/cnb/figures/'+dops[i],im2
    read_png,'/users/cnb/figures/36_pretty_bright.png',im1
    
    im2[*,20:119,20:25]=255B
    im1[*,20:119,20:25]=255B
    

    sz=size(im1)
    fig1=bytarr(3,2*sz[2],sz[3])
    fig1[*,0:sz[2]-1,0:sz[3]-1]=im1
    fig1[*,sz[2]:(2*sz[2]-1),0:sz[3]-1]=im2
    fig1[*,sz[2]-1:sz[2]+1,0:sz[3]-1]=255B
    window,1,xsize=2*sz[2],ysize=sz[3],retain=2
    tv,fig1,/true
    
    write_png,'figure1_'+string(i,format='(i1)')+'.png',fig1
endfor
stop


end
