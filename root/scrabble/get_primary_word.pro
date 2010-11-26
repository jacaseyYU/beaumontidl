;+
; PURPOSE:
;  Given a game board and the location of newly-placed tiles, get the
;  primary word
;
; INPUTS:
;  board: The game board. 15x15 string array
;  new_tiles: Integer 15x15 array. 1 if space i has been placed on
;             this turn
;  pos: The reference position used to place tiles
;  direction: The reference direction used to place tiles
;
; OUTPUTS:
;  The word, as a string
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_primary_word, board, new_tiles, pos, direction
  case direction of
     0: return, get_horizontal_word(board, pos, /single)
     1: return, get_vertical_word(board, pos, /single)
     2: return, get_horizontal_word(board, pos, /single)
     3: return, get_vertical_word(board, pos, /single)
  endcase
  message, 'invalid direction number'
  return, -1
end
  
pro test
  board = get_test_board()
  new = replicate(0, 15, 15)
  new[9,7] = 1
  assert, get_primary_word(board, new, [9,7], 0) eq 'apple'
  assert, get_primary_word(board, new, [9,7], 1) eq 'opa'
  assert, get_primary_word(board, new, [9,7], 2) eq 'apple'
  assert, get_primary_word(board, new, [9,7], 3) eq 'opa'
end
