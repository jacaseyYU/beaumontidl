FUNCTION histeq,image

;perform histogram equalization
image-=min(image)
hist=histogram(image)
avg=mean(hist)
count=0
transf=hist
low=0
for i=0, max(image), 1 do begin
count+=hist[i]
if count ge avg then begin
    transf[low:n_elements(transf)-1]=(low+i)/2.
    low=i+1
    count=0
endif
endfor

result=transf[image]


return,result
end
