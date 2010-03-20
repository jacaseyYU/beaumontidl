FUNCTION hsl2rgb, hue, saturation, lightness
;takes as input three arrays containing the hue,
;saturation, and lightness of an image. hsl2rgb then
;forms an image cube whose three planes are the images
;rgb components.
;
;INPUTS:
;hue,saturation,lightness: three 2D arrays of numbers.
;all values must have range [0,1]
;
;OUTPUT:
;rgb cube, whose values have range [0,255]
;
;Reference: http://en.wikipedia.org/wiki/HSL_color_space

ncol=n_elements(hue[*,0])
nrow=n_elements(hue[0,*])

temp1=fltarr(ncol,nrow)
temp2=fltarr(ncol,nrow)
dark=where(lightness lt 0.5, count)
bright=where(lightness ge 0.5, count2)
if count ne 0 then temp2[dark]=lightness[dark]*(1.0+saturation[dark])
if count2 ne 0 then temp2[bright]=lightness[bright]+saturation[bright]-$
(lightness[bright]*saturation[bright])
temp1=2*lightness-temp2


temp3=fltarr(ncol,nrow,3)
temp3[*,*,0]=(hue+1.0/3.0 mod 1)
temp3[*,*,1]=hue
temp3[*,*,2]=(hue-1.0/3.0 mod 1)

grey=where(saturation[*,*] eq 0,count)

zone1=where(temp3 lt 1.0/6.0,count1)
zone2=where(temp3 gt 1.0/6.0 and temp3 lt .5,count2)
zone3=where(temp3 gt 0.50 and temp3 lt 2.0/3.0, count3)
zone4=where(temp3 gt 2.0/3.0, count4)

rgb=fltarr(ncol,nrow,3)

if count1 ne 0 then rgb[zone1]=temp1[zone1
