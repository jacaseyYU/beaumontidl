function is_word, words
  common scrabble, dictionary
  if n_elements(dictionary) eq 0 then read_dictionary

  ind = value_locate(dictionary, words)
  return, dictionary[[ind]] eq words
end
