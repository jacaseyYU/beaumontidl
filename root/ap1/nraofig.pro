pro swap, vec, a, b
temp=vec[a]
vec[a]=vec[b]
vec[b]=temp
end

pro nraofig

wid=600. ;-square region per bubble
files=file_search('/users/cnb/figures/nrao/*.png')
ct=n_elements(files)
canvas=bytarr(3,6*wid+7*20,4*wid+5*20)
random=[4,7,23,2,19,16,10,11,15,17,8,22,13,0,6,20,1,5,9,14,12,18,21,3]
swap, random,5,13
swap, random, 6, 22
swap, random, 23, 17
swap, random, 22, 23
swap, random, 4, 10
swap, random, 13, 14
swap, random, 10, 16
swap, random, 15, 16
for i=0, 23, 1 do begin
    read_png, files[random[i]],im
    sz=size(im)
    scale=wid/(sz[2]>sz[3])
    im=congrid(im,3,sz[2]*scale,sz[3]*scale,cubic=-0.5)
    sz=size(im)
    im[*,0:10,*]=255B
    im[*,sz[2]-11:sz[2]-1,*]=255B
    im[*,*,0:10]=255B
    im[*,*,sz[3]-11:sz[3]-1]=255B
    off=[(wid-sz[2])/2,(wid-sz[3])/2]
    off+=[(i mod 6)*wid,(i/6)*wid]+[((i mod 6)+1)*20,(i/6+1)*20]
    canvas[0,off[0],off[1]]=im
endfor

write_png,'/users/cnb/figures/sample.png',canvas
write_tiff,'/users/cnb/figures/nraofig.tiff',canvas

end
