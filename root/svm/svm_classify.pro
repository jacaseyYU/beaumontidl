  

function svm_classify, feature, model, outfile = outfile, verbose = verbose
  if ~file_test(feature) then $
     message, 'classification file not found. run feature2file'
  if ~file_test(model) then $
     message, 'Model file not found. run feature2file'

  
  if ~keyword_set(outfile) then outfile = '/tmp/predict'
  spawn, 'svm_classify '+feature+ ' '+model+' '+outfile, stdout
  if keyword_set(verbose) then print, stdout
  readcol, outfile, result, format='(f)', /silent
  return, result
end


