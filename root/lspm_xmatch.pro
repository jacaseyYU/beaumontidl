pro driver
;  file = file_search('/media/cave/catdir*/*/*good.sav')
  file = file_search('/media/data/astrom/*good.sav')
  for i = 0, n_elements(file) - 1, 1 do lspm_xmatch, file[i]
end

pro lspm_xmatch, file
  
  if n_elements(file) eq 0 then $
     file = '/media/cave/catdir.98/n0000/0148.bin.good.sav'

  restore, '~/pro/lspm.sav'
  lspm = data

  restore, file
  print, file

  ra = median(pm.ra)
  dec = median(pm.dec)
 
; plot, pm.ra, pm.dec, $;xra = ra + [-1, 1], $
;       yra = dec + [-1, 1], $
;       psym = 3

  good = where(lspm.ra gt (ra - 1) and $
               lspm.ra lt (ra + 1) and $
               lspm.dec gt (dec - 1) and $
               lspm.dec lt (dec + 1), ct )
  
  if ct eq 0 then begin
     print, 'no overlap between LSPM and catalog'
     return
  endif


  lspm = lspm[good]

;  oplot, lspm.ra, lspm.dec, psym = 5, color = fsc_color('red')

  match = fltarr(ct)
  dist = fltarr(ct)

  for i = 0, ct - 1, 1 do begin
     gcirc, 2, pm.ra, pm.dec, lspm[i].ra, lspm[i].dec, dis
     lo = min(dis, loc)
     dist[i] = lo
     match[i] = loc
     if lo gt 2 then continue
     print, '**********'
     print, '   ', lspm[i].lspm_id, '   ', string(t[loc].obj_id)
     print, lo, format='("   offset: ", f0.1, " arcseconds")'
     print, lspm[i].pmra * 1000, lspm[i].pmdec * 1000, $
            format='("   pm (lepine): ", f0.2, 3x, f0.2)'
     print, pm[loc].ura, pm[loc].udec, $
            format=  '("   pm (me):     ", f0.2, 3x, f0.2)'
     print, sqrt(pm[loc].covar[1,1]), sqrt(pm[loc].covar[3,3]), $
            format=  '("   error:       ", f0.2, 3x, f0.2)'
     print, pm[loc].chisq, pm[loc].ndof, pm[loc].chisq / pm[loc].ndof, $
            format= '("    chisq:       ", f0.2, "    ndof:   ", f0.2, "    red: ", f0.2)'
     print, '**********'
  endfor

  m_pm = sqrt(pm[match].ura^2 + pm[match].udec^2)/1d3
  ra = minmax([lspm.pm, m_pm]) * [.9, 1.1]
;  plot, lspm.pm, m_pm, psym = 4, $
;        xra = ra, yra = ra
;  oplot, [0,1], [0,1]
  
;  pm = sqrt(pm.ura^2 + pm.udec^2) /1d3
 ; h =histogram(pm, loc = loc, nbins = 100)
;  plot, loc, h, psym = 10, yra = [0, 50]
end
