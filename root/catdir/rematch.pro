pro rematch

im = file_search('catdir.107/*/*.cpm')
images = 0
rejections = 0
counts = 0

for j = 0, n_elements(im) - 1, 1 do begin

me = mrdfits(im[j], 1, h)

nim = max(me.image_id)
for i =0, nim, 1 do begin
   hit = where(me.image_id eq i, ct)
   if ct eq 0 then continue
   count, me[hit].ave_ref, val, rep
   images = [images, i]
   rejections = [rejections, total(rep[where(rep ne 1)]) ]
   counts = [counts, ct]
endfor

endfor

sort = sort(images)
for i = 0, n_elements(images) - 1, 1 do begin
   if sort[i] eq 0 then continue
   print, images[sort[i]], rejections[sort[i]], counts[sort[i]], $
          100. * (rejections / counts)[sort[i]], $
          format = "('Image ', i3, ' reject ', i4, ' of ', i4, ' (', i3, ' %)')"
endfor
end
