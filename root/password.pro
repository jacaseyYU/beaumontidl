function password, length, punc = punc, seed = seed
  letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  numbers = '0123456789'
  punctuation = '~!@#$%^&*()-_+={[}]|\:;?/>.<,'
  if keyword_set(punc) then alphabet = letters + numbers + punctuation $
  else alphabet = letters + numbers

  alphabyte = byte(alphabet)
  r = fix(randomu(seed, length) * strlen(alphabet))
  return, string(alphabyte[r])
end
