;+
; PURPOSE:
;  This function returns a list of possible words that can be formed
;  using a player's tiles, along with the tiles in a given
;  row/column of the board.
;
; INPUTS:
;  board: The scrabble baord
;  tiles: The tiles in the player's hand. A string array
;  pos: The reference position. Used, with direction, to determine the
;       relevant row/column
;  direction: The direction to consider -- 0/2 are horizontal
;             words. 1/3 are vertical
;
; KEYWORD PARAMETERS:
;  count: On output, will contain the number of possible words
;
; PROCEDURE:
;  This uses winnow_words to form words out of the letters in tiles
;  and the relevant row/column on the board
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function initial_words, board, tiles, pos, direction, count = count

  ;- extract tiles from the relevant row/column
  if direction eq 0 or direction eq 2 then mask = board[*,pos[1]]
  if direction eq 1 or direction eq 3 then mask = board[pos[0],*]
  hit = where(mask ne '', ct)
  t = ct eq 0 ? tiles : [tiles, mask[hit]]

  return, winnow_words(strjoin(t), count = count)
end


pro test
  board = replicate('', 25, 25)
  tiles=['c','a','t','.']
  t0 = systime(/seconds)
  x=initial_words(board, tiles, [7,7], 0)
  print, systime(/seconds) - t0
  help, x
  t0 = systime(/seconds)
  x=initial_words(board, tiles, [7,7], 0)
  print, systime(/seconds) - t0
  print,x
end
