pro create_board
  common scrabble_board, letters, words
  letters = bytarr(15, 15) + 1
  words = bytarr(15, 15) + 1
 
  ;- lets get this later
;  letter_bonus[[6, 8], [0,0] = 3
;  letter_bonus[[2, 12], [1, 1] = 2
;  letter_bonus[[1, 4, 10, 13], [2, 2, 2, 2]] = 2
;  letter_bonus[[3, 11], [3, 3]] = 3
end
  
  
pro test
  common scrabble_board, letters, words
  create_board
  print, letters, format='(15(i1, 1x))'
  print,''
  print, words, format='(15(i1, 1x))'
end
