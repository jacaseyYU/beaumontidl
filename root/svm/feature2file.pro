function feature2file, feature, outfile = outfile
  nf = n_elements(feature)
  ndim = n_elements(feature[0].feature)
  inds = findgen(ndim) + 1
  fmt = '((i0, 1x, '+strtrim(ndim,2)+'(i0, ":",e0.2, 1x)))'
  fmt2= '((i0, ",", 1x, '+strtrim(ndim-1,2)+'(e0.2, ",", 1x), e0.2))'
  result = strarr(nf)

  records = fltarr(2 * ndim + 1, nf)
  records[indgen(ndim) * 2+1, *] = rebin(inds, ndim, nf)
  records[indgen(ndim) * 2+2, *] = feature.feature
  records[0,*] = feature.label
  result = string(records, format=fmt)

  result2 = string(records[indgen(ndim+1)*2, *], format=fmt2)

  if ~keyword_set(outfile) then $
     outfile = '/tmp/feature.'+string(long(systime(/seconds)),format='(i0)')
  openw, lun, outfile, width = max(strlen(result)), /get
  openw, lun2, strtrun(outfile,'.dat')+'.csv', /get
  printf, lun, result
  printf, lun2, result2
  free_lun, lun
  free_lun, lun2
  save, feature, file=strtrun(outfile,'.dat')+'.sav'
  return, outfile
end
