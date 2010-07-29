;+
; PURPOSE:
;  FInds all the secondary words corresponding to a given turn. The
;  secondary words are those perpendicular to the new tile direction
;
; INPUTS:
;  baord: the board
;  new_tiles: Mask with 1's denoting newly placed tiles
;  pos; The reference position
;  direction: The reference direction
;
; KEYWORD PARAMETERS:
;  count: The number of secondary words
;
; OUTPUTS:
;  An array of secondary words
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_secondary_words, board, new_tiles, pos, direction, count = count

  assert, board[pos[0],pos[1]] ne ''

  result = obj_new('stack')
  hit = where(new_tiles, ct)
  assert, ct ne 0

  h2 = array_indices(board, hit)

  ;- sanity check: Direction of new tiles should match direction
  if ct gt 1 then assert, $
     (range(h2[0,*]) eq 0 && (direction eq 1 || direction eq 3)) || $
     (range(h2[1,*]) eq 0 && (direction eq 0 || direction eq 2))


  for i = 0, ct - 1, 1 do begin
     switch direction of
        0:
        2: begin ;- secondary words are vertical
           x = get_vertical_word(board, h2[*,i])
           if x ne '' then result->push, x
           break
        end
        1:
        3: begin ;- secondary words are horizontal
           x = get_horizontal_word(board, h2[*,i])
           if x ne '' then result->push, x
           break
        end
     endswitch
  endfor   
  array = result->toArray()
  count = result->getSize()
  obj_destroy, result
  return, array
end
        
pro test
  board = get_test_board()
  
  
  new=bytarr(15,15)
  new[8:12, 7] = 1
  assert, get_secondary_words(board, new, [8,7], 0) eq 'opa'
  assert, get_secondary_words(board, new, [8,7], 2) eq 'opa'
  new[*]=0
  new[9,6]=1
  
end
