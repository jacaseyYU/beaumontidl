pro finish_bonus, l1, s1, l2, s2

  common letter_values, values
  if n_elements(values) eq 0 then letter_values
  
  b1 = total(values[byte(l1)])
  b2 = total(values[byte(l2)])

  assert, (b1 eq 0) + (b2 eq 0) eq 1
  
  s1 = (s1 + b2 - b1)
  s2 = (s2 + b1 - b2)
end  
  
