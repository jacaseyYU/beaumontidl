function permutation, array

  common permutation_seed, seed

  sz = n_elements(array)
  return, array[sort(randomu(seed, sz))]

end
