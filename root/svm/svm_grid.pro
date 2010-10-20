function svm_grid, train, test, answers, c, g = g
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
     model = svm_learn(train, outfile='/tmp/model.1', $
                       kernel=kernel, c=data[i].c, g=data[i].g)
     guess = svm_classify(test, model)
     guess = sign(guess)
     data[i].yy = total(guess eq 1 and answers eq 1)
     data[i].yn = total(guess eq 1 and answers eq -1)
     data[i].ny = total(guess eq -1 and answers eq 1)
     data[i].nn = total(guess eq -1 and answers eq -1)
  endfor
  data.recall = 1. * data.yy / (data.yy + data.ny)
  data.precision = 1. * data.yy / (data.yy + data.yn)
  data.accuracy = 1. * (data.yy + data.nn) / n_elements(answers)


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
     

  return, data
end
    

pro gridsearch
  ngrid = 20
;  c = arrgen(1., 2e2, nstep = ngrid, /log)
;  g = arrgen(.01, 1e2, nstep = ngrid, /log)
  clo = 1. & chi = 5000.
  glo = 1e-2 & ghi = 50.
  c = arrgen(clo, chi, nstep = ngrid, /log)
  g = arrgen(glo, ghi,  nstep = ngrid, /log)

  c = rebin(c, ngrid, ngrid)
  g = rebin(1#g, ngrid, ngrid)

  data={c:0., g:0., yy:0, yn:0, ny:0, nn:0, $
        precision:0., recall:0., accuracy:0.}

  data = replicate(data, ngrid, ngrid)
  data.c = c & data.g = g

  ;- a copy of this file
  file = this_file()
  prepare_sims, test, /moment

  ;- loop over grid
  for i = 0, n_elements(data) - 1, 1 do begin
     print, i, n_elements(data)
     model = svm_learn('grid_train.dat', outfile='/tmp/model.1', $
                       kernel = 2, c=data[i].c, g=data[i].g)
     
     guess = svm_classify('grid_test.dat', model)
     guess = sign(guess)
     data[i].yy = total(guess eq 1 and test.label eq 1)
     data[i].yn = total(guess eq 1 and test.label eq -1)
     data[i].ny = total(guess eq -1 and test.label eq 1)
     data[i].nn = total(guess eq -1 and test.label eq -1)
     data[i].recall = 1. * data[i].yy / (data[i].yy + data[i].ny)
     data[i].precision = 1. * data[i].yy / (data[i].yy + data[i].yn)
     data[i].accuracy = 1. * (data[i].yy + data[i].nn) / n_elements(test)
  endfor
;  save, data, file, file='gridsearch_refine.sav'
  save, data, file, file='gridsearch_moment.sav'
end
