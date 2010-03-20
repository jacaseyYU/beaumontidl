pro chiplook
path = '/media/data/catdir.98/'
m = mrdfits(path+'n0000/0148.cpm',1,h)
t = mrdfits(path+'n0000/0148.cpt',1,h)

range = minmax(m.image_id)
h = histogram(m.image_id, reverse = ri, loc = loc)
look = sort(randomn(seed, n_elements(loc)))
for j = 0,n_elements(loc)-1, 1 do begin
   i = look[j]
   if ri[i+1] eq ri[i] then continue
   match = ri[ri[i] : ri[i+1]-1]
   subm = m[match]
   assert, range(subm.photcode) eq 0
   if (subm[0].photcode / 100) eq 1 then continue 
   good = where((subm.phot_flags and 14472) eq 0 and (t[subm.ave_ref].nmeasure gt 30) ,gct, $
                complement = bad, ncomp = bct)
   bad2 = where(t[subm.ave_ref].nmeasure lt 30, b2ct)
   if (gct / bct lt 3) then continue
   title = 'photcode: '+strtrim(subm[0].photcode,2)+' good: '+strtrim(gct,2)+' / '+strtrim(bct, 2)
   plot, subm.x_ccd, subm.y_ccd, psym = 4, xra = minmax(subm.x_ccd)+range(subm.x_ccd)*.05*[-1,1], $
         yra = minmax(subm.y_ccd)+range(subm.y_ccd)*.05*[-1,1], $
         /xsty, /ysty, title = title,/nodata
   if gct ne 0 then oplot, subm[good].x_ccd, subm[good].y_ccd, psym = symcat(16), $
                           color = fsc_color('green')
   if bct ne 0 then oplot, subm[bad].x_ccd, subm[good].y_ccd, psym = symcat(16), $
                           color = fsc_color('red')
   if b2ct ne 0 then oplot, subm[bad2].x_ccd, subm[bad2].y_ccd, psym = symcat(16), $
                            color = fsc_color('blue')
   print, stdev(subm[bad].x_ccd), stdev(subm[good].x_ccd)
   stop
endfor

end
