function sizeline_level, data, seeds, level, chanwid, pixsize, area=area
  mask = data gt level
  r = label_region(mask, /ulong)
  h = histogram(r, min=0, rev = ri)

  size = replicate(!values.f_nan, max(h)+1)
  line = replicate(!values.f_nan, max(h)+1)
  use = bytarr(max(h)+1)
  use[r[seeds]] = 1

  for i = 1L, n_elements(h) - 1, 1 do begin
     if h[i] lt 10 || use[i] eq 0 then continue
     ind = ri[ri[i] : ri[i+1] - 1]

     xyz = array_indices(data, ind)
     t = data[ind]
     tt = total(t, /double, /nan)

     ;- mean location
     x = total(xyz[0,*] * t, /nan) / tt
     y = total(xyz[1,*] * t, /nan) / tt
     z = total(xyz[2,*] * t, /nan) / tt

     dz = total((xyz[2,*] - z) ^ 2. * t, /nan) / tt
     
     covar = cnb_covar(xyz[0:1,*], $
                       paxis = paxis, pvar = pvar, mean = mean, $
                       weights = t)
     assert, abs(mean[0] - x) lt .01 * abs(x)
     assert, abs(mean[1] - y) lt .01 * abs(y)
     
     line[i] = sqrt(dz) * chanwid
     if keyword_set(area) then begin
        ii = 1LL * xyz[0,*] + 1LL * xyz[1,*] * (max(xyz[0,*])+1)
        nproj = n_elements(uniq(ii, sort(ii)))
        size[i] = sqrt(nproj / !pi) * pixsize
     endif else begin
        size[i] = sqrt(sqrt(pvar[0]) * sqrt(pvar[1]) / !pi) * pixsize
     endelse
  endfor

  result = transpose([[size[r[seeds]]], [line[r[seeds]]]])
  return, result
end
  

function sizeline, data, seeds, levels, chanwid = chanwid, pixsize = pixsize, $
                   area = area

  if n_elements(chanwid) eq 0 then $
     chanwid = 1.
  if n_elements(pixsize) eq 0 then pixsize = 1.

  nseed = n_elements(seeds)
  nlev = n_elements(levels)
  size = replicate(!values.f_nan, nseed, nlev)
  linewid = replicate(!values.f_nan, nseed, nlev)

  for i = 0, nlev - 1, 1 do begin
     sl = sizeline_level(data, seeds, levels[i], chanwid, pixsize, area=area)
     size[*, i] = sl[0, *]
     linewid[*, i] = sl[1, *]
  endfor

  return, [[[size]], [[linewid]]]
end
     
