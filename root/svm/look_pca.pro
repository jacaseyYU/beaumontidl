pro look_pca

  restore, '~/m17loop/feature_pca.sav'
  resolve_routine, 'pricom__define'

  ev = pca->get_pc()
  mean = pca->get_mean()
  writefits, 'mean.fits', mean
  for i = 0, 14, 1 do begin
     cube = reform(ev[*,i], 15, 15, 50)
     writefits, 'pc_'+strtrim(i,2)+'.fits', cube
  endfor
end
     
