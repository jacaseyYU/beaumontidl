function sizeline_level_dendro, ptr, i, chanwid, pixsize, area=area
  ind = substruct(i, ptr)
  if n_elements(ind) lt 10 then return, [!values.f_nan, !values.f_nan]
  x = (*ptr).x[ind]
  y = (*ptr).y[ind]
  z = (*ptr).v[ind]
  t = (*ptr).t[ind]
  tt = total(t, /double, /nan)
  ;- velocity
  uz = total(z * t, /nan) / tt
  dz = total((z - uz) ^ 2. * t, /nan) / tt
  
  xy = transpose([[x], [y]])
  covar = cnb_covar(xy, $
                    paxis = paxis, pvar = pvar, mean = mean, $
                    weights = t)

  if keyword_set(area) then begin
     ii = x + 1LL * y * max(x + 1)
     nproj = n_elements(uniq(ii, sort(ii)))
     size = sqrt(nproj / !pi) * pixsize
  endif else begin
     size = sqrt(sqrt(pvar[0]) * sqrt(pvar[1]) / !pi) * pixsize
  endelse
     
  line = sqrt(dz) * chanwid
  return, [size, line]
end
  

function sizeline_dendro, ptr, chanwid = chanwid, pixsize = pixsize, area=area

  if n_elements(chanwid) eq 0 then $
     chanwid = 1.
  if n_elements(pixsize) eq 0 then pixsize = 1.

  nst = n_elements((*ptr).height)
  size = replicate(!values.f_nan, nst)
  line = size
  for i = 0, nst - 1, 1 do begin
     sl = sizeline_level_dendro(ptr, i, chanwid, pixsize, area=area)
     size[i] = sl[0]
     line[i] = sl[1]
  endfor
  return, transpose([[size], [line]])
end
     
