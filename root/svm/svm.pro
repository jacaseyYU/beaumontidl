pro test
  common svm_test, pos, neg
  t0 = systime(/seconds)

  if 1 or n_elements(pos) eq 0 then begin
     print, 'generating features'
     ;- this was the first try - 
     ;- doesn't pick enough of the SNR (esp faint spectra)
     ;neg = mask2feature('train_cloud_3d.sav', label = -1)
     ;pos = mask2feature('train_loop.sav', label = 1)

     ;- these new masks incorporate the '3d box' selections,
     ;- which can pick up the faint spectra better
     neg = mask2feature('train_cloud_bg.sav', label = -1, $
                        bin = [2, 2, 2])
     pos = mask2feature('train_loop_2.sav', label = 1, $
                        bin = [2, 2, 2])

     ;- sort data by y value - should help make training and 
     ;- validation set different
     neg = neg[sort(neg.y)]
     pos = pos[sort(pos.y)]
  endif


  nn = n_elements(neg) & np = n_elements(pos)
  test = [neg[nn-500:*] , pos[np-500:*]]

  lo = 100 & hi = 5d3 < ((nn < np) - 500)
  train_size = arrgen(lo, hi, nstep = 10, /log)
  ntrain = n_elements(train_size)
  score = fltarr(ntrain)
  for i = 0, ntrain - 1, 1 do begin
     train = [neg[0:train_size[i]], pos[0:train_size[i]]]
     model = svm_learn(train)
     guess = svm_classify(test, model, file = guess_file)
     score[i] = total(sign(guess) eq test.label)
     print, score[i], minmax(guess)
  endfor
  print, time2string(systime(/seconds) - t0)
  plot, train_size, score, /ysty
  svm_cleanup

;  test.label = sign(guess)
;  feature2fits, test, 'test.fits', sav = 'test.sav'
  svm_cleanup
  stop
  return
  
end

pro classify_data

  ;- get the training data
  common svm_test, pos, neg
  t0 = systime(/seconds)

  if 1 or n_elements(pos) eq 0 then begin
     print, 'generating features'
;     neg = mask2feature('train_cloud_3and2.sav', label = -1, $
;                        bin = [2,2,2])
;     pos = mask2feature('train_loop.sav', label = 1, $
;                       bin = [2,2,2])
;     neg2 = mask2feature('train_background.sav', label = -1, $
;                        bin=[2,2,2])
;     neg = [neg, neg2]

     neg = mask2feature('train_cloud_bg.sav', label = -1, $
                        bin = [3,3,5])
     pos = mask2feature('train_loop_2.sav', label = 1, $
                        bin = [3,3,5])

     neg = permutation(neg)
     pos = permutation(pos)
;     neg = neg[sort(neg.y)]
;     pos = pos[sort(pos.y)]
  endif
  sz = n_elements(neg) < n_elements(pos)
;  neg = neg[sort(neg.y)]
  neg = permutation(neg)
  training_data = [neg[0:sz-1], pos[0:sz-1]]

  print, 'making model'
  help, training_data
  model = svm_learn(training_data, /verbose)
  
  print, 'reading data'
  ;- read in emission data set
  data = mask2feature('emission_y141.sav', bin=[1, 1, 5])
  print, 'classifying'
  guess = svm_classify(data, model)
  data.label = sign(guess)
  print, 'min max is', minmax(data.label), minmax(guess)

  print, 'writing results'
  feature2fits, data, 'emission_class.fits', sav = 'emission_class.sav', $
                bin = [2, 2, 5]
  save, data, guess, training_data, neg, pos, model, $
        file = 'classify_data.sav'
end
