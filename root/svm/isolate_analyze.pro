pro isolate_analyze

  ;restore, 'm17_contam.sav'
  restore, 'm17_loop_best_2.sav'
  m = mrdfits('mosaic.fits',0,h)

  vels = sxpar(h, 'crval3') + (findgen(sxpar(h,'naxis3')) - sxpar(h, 'crpix3')) * sxpar(h,'cd3_3')
  ;- mask out 15-30 km/s. Too much contamination
  bad = where(vels gt 10 and vels lt 30, comp = comp)
  mbad = m[*,*,bad]
;  m[*,*,bad] = 0

  m = m[*,*,bad]
  vels = vels[bad]
;  m = m[*,*,comp]
;  vels = vels[comp]

  inds = array_indices(mask, where(mask))
  nspec = n_elements(inds[0,*])
  nchan = n_elements(vels)
  data = fltarr(nchan, nspec)
  for i = 0, nspec - 1, 1 do data[*,i] = m[inds[0,i], inds[1,i],*]
;  pca = obj_new('pricom', data)

  restore, 'pca.sav'
  proj = pca->project( data, nterm = 8)
 
  for i = 0, nspec - 1, 1 do begin
     plot, vels, data[*,i], psym = -5
     oplot, vels, proj[*,i], color = fsc_color('blue'), thick = 2
     stop
  endfor
  
  return
  


  mean_spec = fltarr(sxpar(h,'naxis3'))
  for i = 0, n_elements(inds[0,*]) - 1, 1 do begin
     mean_spec += m[inds[0,i], inds[1,i], *]
;     plot, vels, m[inds[0,i], inds[1,i], *]
;     stop
  endfor
  mean_spec /= sxpar(h,'naxis3')
  plot, vels, mean_spec
  stop
end
