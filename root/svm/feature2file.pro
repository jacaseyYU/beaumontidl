
function feature2file, feature, outfile = outfile
  nf = n_elements(feature)
  ndim = n_elements(feature[0].feature)
  inds = findgen(ndim) + 1
  fmt = '((i0, 1x, '+strtrim(ndim,2)+'(i0, ":",e0.2, 1x)))'

  result = strarr(nf)

  records = fltarr(2 * ndim + 1, nf)
  records[indgen(ndim) * 2+1, *] = rebin(inds, ndim, nf)
  records[indgen(ndim) * 2+2, *] = feature.feature
  records[0,*] = feature.label
  result = string(records, format=fmt)

  if ~keyword_set(outfile) then $
     outfile = '/tmp/feature.'+string(long(systime(/seconds)),format='(i0)')
  openw, lun, outfile, width = max(strlen(result)), /get
  printf, lun, result
  free_lun, lun
  save, feature, file=strtrun(outfile,'.dat')+'.sav'
  return, outfile
end
