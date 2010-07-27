pro read_dictionary
  common scrabble, dictionary
  readcol, '~/pro/scrabble/words_medium.txt', dictionary, comment='#', format='a', /silent
end
