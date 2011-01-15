pro svm_tutorial

  num = 20
  ind = findgen(num)

  ;- positive examples
  x1 = randomn(seed, num) - 3 + 5 * (ind gt 10)
  y1 = randomn(seed, num) + 3 - 5 * (ind gt 10)

  ;- negative examples
  x2 = randomn(seed, num) - 3 + 5 * (ind gt 10)
  y2 = randomn(seed, num) - 3 + 5 * (ind gt 10)


  ;- the structure that will hold each example
  ;- the structure MUST have tags named feature and label. 
  ;- extra tags are optional
  rec = {feature:fltarr(2), label:0}

  training_data = replicate(rec, 2 * num)
  training_data.feature[0] = [x1, x2]
  training_data.feature[1] = [y1, y2]
  training_data.label = [replicate(1, num), replicate(-1, num)]
  

  ;- write training data to proper file
  training_file = 'train.dat'
  feature2file, training_data, training_file

  ;- train
  kernel = 2 ;- use RBF kernel
  c = 10 ;- value for C, the misclassification penalty
  g = 1e-4 ;- value for g, the RBF free parameter
  model = svm_learn(file, kernel = kernel, c = c, g = g, outfile = 'model.dat')

  
  ;- create a regular grid of xy points, and classify each point
  ngrid = 300L
  x = arrgen(-5, 7, nstep = ngrid)
  y = arrgen(-6, 6, nstep = ngrid)
  x = rebin(x, ngrid, ngrid) & y = rebin(1#y, ngrid, ngrid)
  class_data = replicate(rec, ngrid^2)
  class_data.feature[0] = reform(x, ngrid^2)
  class_data.feature[1] = reform(y, ngrid^2)
  class_data.label = 0
  class_file = 'class.dat'
  feature2file, class_data, class_file

  ;- classify these data
  guess = svm_classify(class_file, model)

  ;- plot the results
  device, decomposed = 1
  plot, x, y, /nodata, charsize = 1.5
  contour, (guess gt 0), x, y, /fill
  oplot, x1, y1, psym = 4, color = '00ff00'xl
  oplot, x2, y2, psym = 4, color = '0000ff'xl
end
