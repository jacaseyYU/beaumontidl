;-plot locations of stars on chips, examine matches

pro viewMatches, m, a, image

;for i = 0, n_elements(image) - 1, 1 do begin
;   plot, a.ra, a.dec, /nodata
;   hit = where(m.image_id eq i  + 1, ct)
;   if ct eq 0 then continue
;   oplot, a[m[hit].ave_ref].ra, a[m[hit].ave_ref].dec, psym = 4
;   wait, .1
;endfor
;return

;-plot chip boundaries

;loadCatdir, 'catdir.107', m, a, s, n, image
;  colors = reform(fsc_color(/names), 200);
;  colors = colors[30:199]
colors = ['blk5', 'blue', 'crimson', 'red', 'pink','orange', $
          'yellow', 'lime green', 'green', 'forest green']

for i = 0, 35, 1 do begin
   ccd = 'ccd'+string(i, format='(i2.2)')+'.hdr'
   hit = findByExposure(m, image, ccd = ccd, /verbose, count = ct)
   ct = n_elements(hit)
 
  if ct eq 0 then continue
 
goto, skip
;*********************
;- this isn't used!
;*********************
   images = m[hit].image_id
   images = images[sort(images)]
   images = images[uniq(images)]
   print, image[images - 1].name
   nim = n_elements(images)

   for j = 0, (100 < nim) - 1, 1 do begin
      im = images[j]
      ihit = where(m.image_id eq im)
      subm = m[ihit]
      suba = a[subm.ave_ref]

;      good = where(suba.nmeas gt 1, nct)
;
;     if nct lt 2 then begin
;        print, 'no multi-measures'
;        continue
;     endif
;
;      suba = suba[good]
;      subm = subm[good]

      if j eq 0 then begin
         plot, a[m[hit].ave_ref].ra, a[m[hit].ave_ref].dec, $
               psym = 4, color = fsc_color('white'),/nodata
      endif
         oplot, suba.ra + 0 * subm.d_ra / 3600., suba.dec + 0 * subm.d_dec / 3600., $
                psym = 4, color = fsc_color(colors[j])
      endfor
   wait, 2
   
;***********
;resume
;**********
skip:

   subm = m[hit]
   suba = a[m[hit].ave_ref]
   
   plot,suba.ra, suba.dec, /nodata, color = fsc_color('white'), title = ccd
   
   for j = 1, 10 < max(suba.nmeas) do begin
      good = where(suba.nmeas eq j, ct)
      xyouts, .8, .9 - .02 *j, 'nmeas = '+strtrim(string(j), 2), $
              color = fsc_color(colors[j - 1]), /norm, charsize = 1.5
      if ct le 2 then continue
      oplot, suba[good].ra, suba[good].dec, $
             color = fsc_color(colors[j - 1]), psym = 4, symsize = .05 + j / 3.
   endfor
   stop
endfor

end
      
   
