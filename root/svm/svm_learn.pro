;+
; PURPOSE:
;  This function trains the SVM algorithm on a given data set. It is a
;  wrapper to the svm_learn command line program in the SVMLight
;  software package. For more details about the algorithm and its free
;  parameters, consult svmlight.joachims.org.
;
; INPUTS:
;  feature: The name of a SVM feature file (created, e.g., with
;           feature2file)
;
; KEYWORD PARAMETERS:
;  kernel: An integer specifying which kernel function to use. 
;  c: Override the default value for the mis-classification
;     penalty. Higher values penalize misclassification more strongly.
;  d: Override the d parameter in the polynomial kernel
;  g: Override gamma parameter in the radial basis function kernel
;  s: Override s parameter in sigmoid/poly kernel
;  r: Override c parameter in sigmoid/poly kernel
;  u: Override u parameter in user-defined kernel
;  verbose: Set to a non-zero value to print info
;  precision: On output, contains the precision at which the training
;             data are fit.
;  recall: On output, contains the recall at which the training data
;          are fit. 
;  error: On output, contains an estimate of the error
;  vc: On output, contains the VC dimension of the classification
;  training_error: On output, contains the error when classifying the
;                  training data.
;  outfile: The name of a file to write the results to. Default to 'svm_learn.dat'
;
; OUTPUTS:
;  The name of the file containing the parameters of the trained
;  model.
;
; MODIFICATION HISTORY:
;  2010: Written by Chris Beaumont
;-  
function svm_learn, feature, kernel = kernel, c = c, $
               d = d, g = g, s = s, r = r, u = u, $
               verbose = verbose, $
               precision = precision, recall = recall,$
               error = error, vc = vc, $
               training_error = training_error, $
               outfile = outfile
  
  if ~file_test(feature) then message, 'Must supply a valid training file'
  if keyword_set(outfile) then outname = outfile else $
     outname = 'svm_learn.dat'
  
  
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
  catch, theError
  if theError ne 0 then begin
     catch, /cancel
     print, 'Error parsing execution summary. Do not trust the output keywords!'
     return, outname
  endif

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
