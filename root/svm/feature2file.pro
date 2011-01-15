;+
; PURPOSE:
;  This procedure writes the contents of a SVM data set to a file
;
; INPUTS:
;  feature: An array of SVM structures. Each structure must have the
;  tags FEATURE and LABEL.
;  outfile: The name of a file to write to. 
;
; BEHAVIOR:
;  The feature vector is converted into a file compatible for use with
;  the SVMLight command line tool
;
; MODIFICATION HISTORY:
;  2010: Written by Chris Beaumont
;-
pro feature2file, feature, outfile, names=names
  if n_params() ne 2 then begin
     print, 'Calling sequence'
     print, ' feature2file, feature, outfile'
     return
  endif

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

  openw, lun, outfile, width = max(strlen(result)), /get
  openw, lun2, strtrun(outfile,'.dat')+'.csv', /get
  if keyword_set(names) then printf, lun2, names
  printf, lun, result
  printf, lun2, result2
  free_lun, lun
  free_lun, lun2
  save, feature, file=strtrun(outfile,'.dat')+'.sav'
  return
end
