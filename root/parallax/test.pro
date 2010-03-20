pro test
  
  dir = '/media/cave/catdir.98/n0000/0149'
  m = mrdfits(dir+'.cpm', 1, h)
  t = mrdfits(dir+'.cpt',1,h)
  good = where(t[m.ave_ref].nmeasure gt 100)
  m = m[good]
  h = histogram(m.image_id, loc = loc)
  sort = reverse(sort(h))

  h2 = histogram(h, loc = loc)
  plot, loc, h2, psym = 10
  stop
  return

  for i = 0, n_elements(sort) - 1, 1 do begin
     good = where(m.image_id eq loc[sort[i]], ct)
     plot, m[good].mag, sqrt(m[good].d_ra^2 + m[good].d_dec^2), psym = 3, /ylog, $
           title = strtrim(ct)
     wait, 2
  endfor

end
