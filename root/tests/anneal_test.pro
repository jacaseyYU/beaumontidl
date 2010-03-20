function anneal_test::selectTrial, state
  return, state * (1 + .2 * (randomu(seed) - .5))
end

function anneal_test::fitness, state
  return, -(state - 40D)^2
end
  
pro anneal_test__define
  data = {anneal_test, inherits anneal}
end

pro anneal_test
  test = obj_new('anneal_test', 5., 1000, /save)
  test->run
  states = test->getAllStates(fitnesses = fitness)
  plot, states
  obj_destroy, test
end
