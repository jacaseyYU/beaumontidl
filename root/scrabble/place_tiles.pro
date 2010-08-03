;+
; PURPOSE:
;  This function places tiles onto a board at a specified position and
;  direction. It "hops over" occupied spaces, potentially creating
;  words that utilize tiles on the board.
;
; INPUTS:
;  old_board: The current board
;  tiles: A string array of tiles to place on the board
;  pos: The reference position for the current turn
;  direction: The tile placement direction. Words start/end at pos and
;             flow left/down/right/up from that point, for dir 0-3
;
; OUTPUTS:
;  new_board: The new board, containing tiles. 
;  new_tiles: A 15x15 byte mask, indicating what spaces the new tiles
;             went to. 
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function place_tiles, old_board, tiles, $
                      pos, direction, $
                      new_board, new_tiles
  
  new_board = old_board
  new_tiles = bytarr(15, 15)
  
  todo = n_elements(tiles)
  ind = 0
  p = pos
  while todo ne 0 do begin
     assert, tiles[ind] ne ''
     ;- failure?
     if (p[0] lt 0) || (p[0] gt 14) || (p[1] lt 0) || (p[1] gt 14) then begin
        new_tiles *= 0
        new_board[*] = ''
        return, 0
     endif

     ;-occupied?
     if new_board[p[0], p[1]] eq '' then begin
        new_board[p[0], p[1]] = tiles[ind++]
        new_tiles[p[0], p[1]] = 1
        todo -= 1
     endif
     ;- update positions
     if direction eq 0 then p[0] += 1
     if direction eq 1 then p[1] += 1
     if direction eq 2 then p[0] -= 1
     if direction eq 3 then p[1] -= 1
  endwhile
  return, 1
end


pro test
  board = get_test_board()

  assert, place_tiles(board, ['x'], [3,7], 0, new_board, new_tiles)
  assert, new_tiles[3,7] && total(new_tiles) eq 1
  assert, place_tiles(board, ['x','y'], [3,7], 0, new_board, new_tiles)
  assert, new_board[3,7] eq 'x' && new_board[7,7] eq 'y'
  assert, new_tiles[3,7] eq 1 && new_tiles[7,7] eq 1 && total(new_tiles) eq 2

  assert, place_tiles(board, ['x','y'], [9,5], 1, new_board, new_tiles)
  assert, new_board[9,5] eq 'x' && new_board[9,9] eq 'y'
  assert, new_tiles[9,5] eq 1 && new_tiles[9,9] eq 1 && total(new_tiles) eq 2

end
