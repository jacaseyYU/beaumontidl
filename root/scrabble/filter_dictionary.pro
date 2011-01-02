pro filter_dictionary, vocabsize

  common scrabble, dictionary, letter_freq, len_ri
  read_dictionary
  restore, 'word_freq.sav'
  assert, n_elements(dictionary) eq n_elements(letter_freq[0,*])

  num = n_elements(s)
  hi = (vocabsize < num) - 1
  s = s[0:hi]
  s = s[sort(s)]
  
  dictionary = dictionary[s]
  letter_freq = letter_freq[*,s]

  h = histogram(strlen(dictionary), min = 0, rev = len_ri)
end
