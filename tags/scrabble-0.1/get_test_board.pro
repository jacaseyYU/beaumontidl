;+ 
; PURPOSE:
;  Return a test board for debugging / testing purpose
;
; OUTPUTS:
;  A simple scrabble board
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_test_board
  board = replicate('', 15, 15)

  board[8:12, 7]=['a', 'p', 'p', 'l', 'e']
  board[4:6, 7]=['t','h','e']
  board[9, 6:8]=['o','p','a']
  return, board
end
