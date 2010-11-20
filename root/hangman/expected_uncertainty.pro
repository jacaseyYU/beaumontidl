function expected_uncertainty, partial, excludes, guess, wordbytes, tiebreaker = tb, wait = wait

  a = (byte('a'))[0] & z = (byte('z'))[0]
  dot = (byte('.'))[0]

  p_freq = histogram(byte(partial), min = a, max = z)
  if n_elements(excludes) eq 0 then e_freq = bytarr(26) else $
     e_freq = histogram(byte(excludes), min = a, max = z)
  done = where(p_freq ne 0 or e_freq ne 0, donect)
  
  ;- make a mask for each possible word 
  ;- like 'b.a.n' where '.' are not yet revealed
  ;- and letters have been guessed

  hitmask = wordbytes * 0B
  for j = 0, n_elements(guess) -1, 1 do begin
     hitmask or= ((wordbytes eq guess[j]) ne 0)
     mask = wordbytes * hitmask + (~hitmask) * dot
     mask = string(mask)
     wordct = n_elements(mask)
     ;- count the frequency of each unique mask
     states = mask[uniq(mask, sort(mask))]
     if n_elements(states) eq 1 then $
        h = wordct $
     else $
        h = histogram(value_locate(states, mask))
     p = 1. * h / total(h)
     result = total(h * p)
     if result eq 1 then begin
        tb = j
        return, 1
     endif
  endfor
  tb = n_elements(guess) - 1
  return, result
end
