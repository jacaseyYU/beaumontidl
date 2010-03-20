pro gauss_like_test

  seed = 5
  small_data = randomn(seed, 1)
  med_data = randomn(seed, 100)
  big_data = randomn(seed, 1000)

  o1 = obj_new('gauss_like', small_data)
  o2 = obj_new('gauss_like', med_data)
  o3 = obj_new('gauss_like', big_data)


  model_1 = [0, 1]
  model_2 = [1, 2]

  print, alog(o1->likelihood(model_1)), o1->loglikelihood(model_1), alog(1 / sqrt(2D * !dpi) * exp(-small_data^2/2))
  print, alog(o2->likelihood(model_1)), o2->loglikelihood(model_1)
  print, alog(o3->likelihood(model_1)), o3->loglikelihood(model_1)


  obj_destroy, o1
  obj_destroy, o2
  obj_destroy, o3

end
