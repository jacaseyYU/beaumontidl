pro count

ims = file_search('train_[xy]*sav')
ct = 0
for i = 0, n_elements(ims)-1, 1 do begin
   restore, ims[i]
   ct += total(mask)
   sz = n_elements(mask)
endfor

print, ct, sz, 1d * ct / sz
m = mrdfits('mosaic.fits')
print, ct/ total(finite(m))
end
