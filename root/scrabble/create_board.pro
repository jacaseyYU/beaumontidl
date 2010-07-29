;+
; PURPOSE:
;  Creates and populates a common block to hold the letter and word
;  bonuses on a scrabble board, as well as an array to keep track of
;  which played tiles are blanks.
;
; INPUTS;
;  l: On output, holds the letter bonuses. A 15x15 integer array
;  w: On output, holds the word bonuses.
;
; COMMON BLOCKS:
;  scrabble_board: holds letters, words, blanks. All 15x15 integer
;  arrays.
;
; NOTES:
;  The letter/word bonus pattern corresponds to Words with Friends,
;  and not the original scrabble board.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
pro create_board, l, w
  common scrabble_board, letters, words, blanks
  letters = intarr(15, 15) + 1
  words = intarr(15, 15) + 1

  letters=[[1, 1, 1, 1, 1, 1, 3, 1, 3, 1, 1, 1, 1, 1, 1], $
           [1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1], $
           [1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1], $
           [1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1], $
           [1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2, 1, 1], $
           [1, 1, 1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1, 1, 1], $
           [3, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3], $
           
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           
           [3, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3], $
           [1, 1, 1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1, 1, 1], $
           [1, 1, 2, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2, 1, 1], $
           [1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1], $
           [1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1], $
           [1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1], $
           [1, 1, 1, 1, 1, 1, 3, 1, 3, 1, 1, 1, 1, 1, 1]]
  l = letters
  words = [[1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1], $
           [1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1], $
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           [3, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 3], $
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           [1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1], $
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           
           [1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1], $

           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           [1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1], $
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           [3, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 3], $
           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], $
           [1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1], $
           [1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1]]
  w = words
  blanks = replicate(0, 15, 15)
end
  
  
pro test
  common scrabble_board, letters, words
  create_board
  print_board, letters
  print,''
  print_board, words
end
