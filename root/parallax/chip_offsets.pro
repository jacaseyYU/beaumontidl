pro chip_offsets

  common chip_offsets, im, m, t
  if n_elements(im) eq 0 then begin
     im = mrdfits('/media/cave/catdir.98/Images.dat', 1,h)
     m = mrdfits('/media/cave/catdir.98/s0000/4801.cpm',1,h)  
     t = mrdfits('/media/cave/catdir.98/s0000/4801.cpt',1,h)
  endif
  
  ;- group images by image name                                                              
  names = strmid(im.name, 0, 14)
  names = names[uniq(names)]
  nexp = n_elements(names)
  x = fltarr(nexp) * !values.f_nan
  y = fltarr(nexp) * !values.f_nan
  jd = x
  

  good = where((m.phot_flags and 14728) ne 0, ct)
  m = m[good]

  m_name = im[m.image_id - 1].name
  
  for i = 0L, nexp - 1, 1 do begin
     print, strtrim(i,2)+' of '+strtrim(nexp - 1,2)
     
     hit = where(strmatch(m_name, names[i]+'*'), ct)
     if ct eq 0 then continue
     ;print, '    ', ct
     x[i] = wmean(m[hit].d_ra, 1 / m[hit].mag_err^2, /nan)
     y[i]  = wmean(m[hit].d_dec, 1 / m[hit].mag_err^2, /nan)
     assert, range(m[hit].time) eq 0
     jd[i] = linux2jd(m[hit[0]].time)
     ;print, '    ', x[i], y[i]

  endfor

  plot, x, y, psym = 4
  par_factor, median(t.ra), median(t.dec), jd, pr, pd
  
  stop
end
