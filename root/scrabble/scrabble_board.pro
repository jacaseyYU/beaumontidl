pro scrabble_board, letter_bonus, word_bonus
  common
  letter_bonus = bytarr(15, 15) + 1
  word_bonus = bytarr(15, 15) + 1
  
  letter_bonus[[6, 8], [0,0] = 3
  letter_bonus[[2, 12], [1, 1] = 2
  letter_bonus[[1, 4, 10, 13], [2, 2, 2, 2]] = 2
  letter_bonus[[3, 11], [3, 3]] = 3
  
  
  
  
