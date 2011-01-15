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
