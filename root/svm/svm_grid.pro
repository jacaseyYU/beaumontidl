;+
; PURPOSE:
;  This function performs a simple gridsearch to optimize the free
;  parameters in the SVM algorithm. This function only supports the
;  linear (default) and radial basis function kernel functions. 
;
; INPUTS:
;  train: The file name of a training file. Created with feature2file.
;  test: The name of a test file. Created with feature2file.
;  answers: An array of integers, one for each test example. These
;           give the correct classification (-1 or 1) for each test example.
;  c: An array of c values. An SVM classifier will be trained using
;     each value of c (the penalty factor for misclassifications).
;
; KEYWORD PARAMETERS:
;  g: An optional vector of g values (i.e. the gamma parameter for the
;     radial basis kernel function). If present, the radial basis
;     kernel function is used, and a classifier is traned for each
;     combination of (c,g). If not provided, the linear kernel is
;     used.
;  verbose: Set to 1 to print a summary
;
; BEHAVIOR:
;  An SVM classifier is trained on the training data for each value of
;  c and, optionally, g. This classifier is then applied to the test
;  data set. The performace of each classifier is measured and
;  returned as a structure.
;
; OUTPUTS:
;  An array of structures, one for each classifier tested. Each
;  structure has the following tags:
;   c: The value of c used
;   g: The value of g used
;  yy: The number of test cases correctly identified as positive
;      ('yes')
;  yn: The number of test cases incorrectly identified as positive
;  ny: The number of test cases incorrectly identified as negative
;  nn: The number of test cases correctly identified as negative
;  precision: The fraction of positive classifications that are
;             correct
;  recall: The fraction of positive test cases that are correctly
;          identified
;  accuracy: The fraction of test cases correctly identified.
;
; MODIFICATION HISTORY:
;  2010: Written by Chris Beaumont
;-
function svm_grid, train, test, answers, c, g = g, verbose = verbose
  if n_params() ne 4 then begin
     print, 'calling sequence:'
     print, ' result = svm_grid(train, test, answers, c, [g = g])'
     return, -1
  endif
  if ~file_test(train) then $
     message, 'Cannot find training file'
  if ~file_test(test) then $
     message, 'Cannot find test file'

  nc = n_elements(c)
  ng = n_elements(g)
  if nc eq 0 then $
     message, 'Must provide a vector of C values to try'
  
  kernel = ng eq 0 ? 0 : 2
  
  cgrid = ng eq 0 ? c : rebin(c, nc, ng)
  ggrid = ng eq 0 ? 1 : rebin(1#g, nc, ng)

  data = {c:0., g:0., yy:0, yn:0, ny:0, nn:0, $
          precision:0., recall:0., accuracy:0.}
  data = replicate(data, nc, ng>1)
  data.c = cgrid
  data.g = ggrid

  for i = 0, n_elements(data) - 1, 1 do begin
     print, i, data[i].c, data[i].g
     model = svm_learn(train, outfile='model.grid.tmp', $
                       kernel=kernel, c=data[i].c, g=data[i].g)
     guess = svm_classify(test, model, outfile='guess.grid.tmp')
     guess = sign(guess)
     data[i].yy = total(guess eq 1 and answers eq 1)
     data[i].yn = total(guess eq 1 and answers eq -1)
     data[i].ny = total(guess eq -1 and answers eq 1)
     data[i].nn = total(guess eq -1 and answers eq -1)
  endfor
  spawn, 'rm model.grid.tmp guess.grid.tmp', stdout, stderr
  data.recall = 1. * data.yy / (data.yy + data.ny)
  data.precision = 1. * data.yy / (data.yy + data.yn)
  data.accuracy = 1. * (data.yy + data.nn) / n_elements(answers)

  if keyword_set(verbose) then begin
     ;- summarize results
     mpre = max(data.precision, preloc)
     mre = max(data.recall, reloc)
     macc = max(data.accuracy, aloc)
     
     if ng eq 0 then begin
        fmt='(a, e8.2, 3x, "c= ", e8.2)'
        print, "Max Precision: ", mpre, data[preloc].c, format=fmt
        print, "Max Recall:    ", mre, data[reloc].c, format=fmt
        print, "Max Accuracy:  ", macc, data[aloc].c, format=fmt
     endif else begin
        fmt='(a, e8.2, 2x, "c= ", e8.2, 2x, "g= ", e8.2)'
        print, "Max Precision: ", mpre, data[preloc].c, data[preloc].g, format=fmt
        print, "Max Recall:    ", mre, data[reloc].c, data[reloc].g, format=fmt
        print, "Max Accuracy:  ", macc, data[aloc].c, data[aloc].g, format=fmt
     endelse
  endif

  return, data
end
    

