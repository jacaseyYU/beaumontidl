;+
; A dumb strategy, which guesses a-z in alphabetical order
;-
function guess_dumb, partial, excludes
  
  a = (byte('a'))[0] & z = (byte('z'))[0]
  
  ;- find the first letter that hasn't been guessed
  p_h = histogram(byte(partial), min=a, max=z)
  if n_elements(excludes) ne 0 then $
     e_h = histogram(byte(excludes), min=a, max=z) $
  else e_h = replicate(0, 26)

  result = where(p_h eq 0 and e_h eq 0)
  return, string(byte(result[0]) + a)
end  
     
