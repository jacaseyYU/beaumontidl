function expected_uncertainty, partial, excludes, guess, wordbytes

  a = (byte('a'))[0] & z = (byte('z'))[0]
  dot = (byte('.'))[0]

  p_freq = histogram(byte(partial), min = a, max = z)
  if n_elements(excludes) eq 0 then e_freq = bytarr(26) else $
     e_freq = histogram(byte(excludes), min = a, max = z)
  done = where(p_freq ne 0 or e_freq ne 0, donect)
  
  ;- make a mask for each possible word 
  ;- like 'b.a.n' where '.' are not yet revealed
  ;- and letters have been guessed
     
  hitmask = (wordbytes eq guess) ne 0
  for j = 0, donect -1, 1 do $
     hitmask or= (wordbytes eq done[j] + a)
  mask = wordbytes * hitmask + (~hitmask) * dot
  mask = string(mask)
  wordct = n_elements(mask)
  
  ;- count the frequency of each unique mask
  states = mask[uniq(mask, sort(mask))]
  if n_elements(states) eq 1 then return, wordct

  ind = value_locate(states, mask)
  h = histogram(ind)
  p = 1. * h / total(h)
  return, total(h * p)
end
