function guess_minmax_prune, partial, excludes, wordlist = wordlist
  
  if keyword_set(wordlist) then wl = wordlist

  a = byte('a') & z = byte('z')

  partial_freq = histogram(byte(partial), min = a, max = z)
  excludes_freq = n_elements(excludes) ne 0 ? $
                  histogram(byte(excludes), min = a, max = z) : $
                  bytarr(26)

  words = possible_words(partial, excludes, wordlist = wl, count = nword)

  if nword eq 0 then return, !values.f_nan

  freq = intarr(26, nword)
  for i = 0, nword - 1, 1 do freq[*,i] = histogram(byte(words[i]), min=a, max=z)

  fitness = lonarr(26) - 1
  for i = 0, 25, 1 do begin
     already_guessed = (partial_freq[i] ne 0) || (excludes_freq[i] ne 0)
     if already_guessed then continue

     n_inc = total(freq[i,*])
     n_exc = nword - n_inc
     fitness[i] = nword - (n_inc > n_exc)
  endfor
  best = max(fitness, loc)
  return, string(byte(loc) + a)
end

pro test
     
  dictionary=['abe', 'gob', 'lob']
  guess='...'
  answer = guess_minmax_prune(guess, excludes, wordlist = dictionary)
  assert, answer eq 'a'
  answer = guess_minmax_prune(guess, 'a', wordlist = dictionary)
  assert, answer eq 'g'
  print, 'all tests passed'
end
