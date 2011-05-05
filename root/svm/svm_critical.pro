function svm_critical, model

  if n_params() ne 1 || size(model, /tname) ne 'STRING' then begin
     print, 'calling sequence'
     print, 'result = svm_critical(model_file)'
     return, !values.f_nan
  endif

  if ~file_test(model) then $
     message, 'File not found: '+model

  openr, lun, model, /get
  skip_lun, lun, 11, /lines
  line = ' '
  readf, lun, line, format='(a)'
  free_lun, lun

  split = strsplit(line, ' ', /extract)
  vec= split[1:n_elements(split)-2]
  nvec = n_elements(vec)

  feature = {feature:fltarr(nvec), label:0}
  for i = 0, nvec - 1, 1 do $
     feature.feature[i] = (strsplit(vec[i],':', /extract))[1]

  file = '/tmp/feature_svmcrit.txt'
  feature2file, feature, file
  c = svm_classify(file, model, outfile='/tmp/feature_class.txt')

  return, abs(c[0]) * [-1, 1]
end
