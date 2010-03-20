function extinction, dist, b, av

  dust_height = 100D
  l_eff = abs(dust_height / sin(b * !dtor)) < dist
  if n_elements(av) eq 1 then return, l_eff * av
  return, l_eff ## av
end
