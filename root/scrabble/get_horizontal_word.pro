;+
; PURPOSE:
;  This function finds the horizontal word passing through a position
;
; INPUTS:
;  board: The game board
;  pos: The 2-element reference position
;
; KEYWORD PARAMETERS:
;  single: If set, consider a single letter word to be valid. Otherwise,
;  require words to be 2 letters or more.
;
; OUTPUTS:
;  The word (not-necessarily a valid english word) passing through
;  pos, or the empty string if no such word exists.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_horizontal_word, board, pos, single = single
  row_mask = bytarr(15,15) & row_mask[*, pos[1]] = 1
  mask = board ne '' and row_mask
  assert, total(mask) ne 0
  if total(mask) eq 1 then $
     return, keyword_set(single) ? board[where(mask)] : ''

  conn = label_region_edge(mask)
  hit = where(conn eq conn[pos[0], pos[1]], ct)
  assert, conn[pos[0], pos[1]] ne 0
  if ct eq 1 then return, keyword_set(single) ? board[hit[0]] : ''
  
  h2 = array_indices(board, hit)
  cols = minmax(h2[0,*])
  row = h2[1,0]
  
  return, (strjoin(board[cols[0]:cols[1], row]))[0]
end

pro test
  board = get_test_board()
  assert, get_horizontal_word(board, [8,7]) eq 'apple'
  assert, get_horizontal_word(board, [9,7]) eq 'apple'
  assert, get_horizontal_word(board, [9,6]) eq ''
  assert, get_horizontal_word(board, [6,7]) eq 'the'
end
