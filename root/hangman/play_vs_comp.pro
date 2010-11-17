pro play_vs_comp

  common scrabble, dictionary, letter_freq, len_ri
  if n_elements(dictionary) eq 0 then read_dictionary

  word = floor(randomu(seed) * n_elements(dictionary))
  word = dictionary[word]

  play_hangman, word, nguess = ng, guessfunc = 'guess_human'

  print, "My Turn, bitch"
  play_hangman, word, nguess = ng2

  print, ng, ng2, format='("Final score: ", i2, " to ", i2)'
  if ng2 lt ng then print, 'I Win!!!' 
  if ng lt ng2 then print, 'You win. grrr'
  if ng eq ng2 then print, 'Tie'
end
