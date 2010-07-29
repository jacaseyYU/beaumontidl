function winnow_words, word, count = count
  common scrabble, dictionary, letter_freq
  if n_elements(dictionary) eq 0 then read_dictionary
  
  n_blank = 0
  p = strpos(word, '.', 0)
  while p ne -1 do begin
     n_blank ++
     p = strpos(word, '.', p+1)
  endwhile

  freq = letter_freq(word)
  freq = rebin(freq, 26, n_elements(dictionary))
  
  off = total((letter_freq - freq) * (letter_freq ge freq), 1)
  valid = where(off le n_blank, count)
  if count eq 0 then return, -1 else return, dictionary[valid]
end
