function co_pop_frac, level, temperature, nlevel = nlevel

  if ~keyword_set(nlevel) then nlevel = 100
  levels = indgen(nlevel)
  weights = 2 * levels + 1
  energies = 5.53 / 2 * levels * (levels + 1)

  fracs = weights * exp(-energies / temperature)
  fracs /= total(fracs)
  return, fracs[level]

end

