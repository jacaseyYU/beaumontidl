function svm_learn, feature, kernel = kernel, c = c, $
                    d = d, g = g, s = s, r = r, u = u, $
                    verbose = verbose, $
                    precision = precision, recall = recall,$
                    error = error, vc = vc, $
                    training_error = training_error, $
                    outfile = outfile
  
  if ~file_test(feature) then message, 'Must supply a valid training file'
  if keyword_set(outfile) then outname = outfile else $
     outname = '/tmp/model.'+string(long(systime(/seconds)),format='(i0)')
  
  
  ;- form keyword arguments
  args = ''
  if keyword_set(kernel) then args += '-t '+strtrim(kernel,2)+' '
  if keyword_set(c) then args += '-c '+strtrim(c, 2)+' '
  if keyword_set(d) then args += '-d '+strtrim(d, 2)+' '
  if keyword_set(g) then args += '-g '+strtrim(g, 2)+' '
  if keyword_set(s) then args += '-s '+strtrim(s, 2)+' '
  if keyword_set(r) then args += '-r '+strtrim(r, 2)+' '
  if keyword_set(u) then args += '-u '+strtrim(u, 2)+' '

  ;- invoke svm_learn
  cmd = 'svm_learn '+args+' '+feature+' '+outname
  spawn, cmd, stdout
  if keyword_set(verbose) then print, stdout
  if keyword_set(verbose) then print, 'Spawn command: ', cmd
  ;- parse the output to get diagnostics
  row = where(strmatch(stdout, 'Estimated VCdim*'))
  ii = strpos(stdout[row], '<=')
  vc = float(strmid(stdout[row], ii+2))
 
  row = where(strmatch(stdout, '*estimate of the error:*'))
  ii = strpos(stdout[row], '<=') & jj = strpos(stdout[row], '%')
  error = float(strmid(stdout[row], ii+2, jj-ii-2)) / 100.

  row = where(strmatch(stdout, '*estimate of the recall*'))
  ii = strpos(stdout[row], '=>') & jj = strpos(stdout[row], '%')
  recall = float(strmid(stdout[row], ii+2, jj-ii-2)) / 100.

  row = where(strmatch(stdout, '*estimate of the precision*'))
  ii = strpos(stdout[row], '=>') & jj = strpos(stdout[row], '%')
  precision = float(strmid(stdout[row], ii+2, jj-ii-2)) / 100.

  row = where(strmatch(stdout, 'Optimization finished*'))
  ii = strpos(stdout[row], '(') & jj = strpos(stdout[row], ' misclassified')
  training_error = float(strmid(stdout[row], ii+1, (jj - ii - 1))) / $
                   n_elements(feature)
  return, outname
end
