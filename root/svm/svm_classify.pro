;+
; PURPOSE:
;  This function applies a trained SVM classifier to a new set of
;  data.
;
; INPUTS:
;  feature: The file name of a SVM feature set. Created, e.g., with
;           feature2file
;  model: The file name of an SVM model. Created with svm_learn
;
; KEYOWRD PARAMETERS:
;  verbose: Set to print output
;  outfile: The file to write the classification results to. Defaults
;           to svm_classify.dat
;
; OUTPUTS:
;  A set of numbers, one for each object in the feature file. The sign
;  of the number (i.e. negative or positive) denotes the
;  classification of each object. Larger absolute values presumably
;  denote more confident classifications.
;
; PROCEDURE:
;  A wrapper program to the command-line utility svm_classify, in the
;  SVMLight software package. See svmlight.joachims.org for details.
;
; MODIFICATION HISTORY:
;  2010: Written by Chris Beaumont
;-
function svm_classify, feature, model, outfile = outfile, verbose = verbose
  compile_opt idl2
  on_error, 2

  if n_params() ne 2 then begin
     print, 'Calling sequence'
     print, ' result = svm_classify(feature, mode, [outfile = outfile, /verbose])'
     return, !values.f_nan
  endif

  if ~file_test(feature) then $
     message, 'classification file not found. run feature2file'
  if ~file_test(model) then $
     message, 'Model file not found. run feature2file'
  
  if ~keyword_set(outfile) then outfile = 'svm_classify.dat'
  spawn, 'svm_classify '+feature+ ' '+model+' '+outfile, stdout, stderr
  if keyword_set(verbose) then print, stdout
  if n_elements(stderr) ne 1 || stderr ne '' then begin
     print, 'svm_classify error:'
     print, stderr
     print, 'Aborting'
     return, !values.f_nan
  endif

  openr, lun, outfile, /get
  nline = file_lines(outfile)
  result = fltarr(nline)
  readf, lun, result
  free_lun, lun

  return, result
end


