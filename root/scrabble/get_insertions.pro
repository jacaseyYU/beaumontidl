;+
; PURPOSE:
;  This procedure is a helper function to find_insertions. It finds
;  all relevant insertions for a given position and direction
;
; INPUTS:
;  board: The board
;  x: initial X point of insertion
;  y: initial Y point of insertion
;  indices: indices stack
;  directions: directions stack
;  minlengths: minlengths stack
;
; PROCEDURE:
;  Adds all of the tiles within 7 spaces of x,y, with associated
;  minlengths such that any words at those positions pass through x,y
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;  July 28: Realized that only directions 0,3 need be considered, and
;  only tiles to the left / above each ref pos need be considered. cnb.
;-
pro _add_squares, board, x, y, indices, directions, minlengths
  
  for dx = 0, -7, -1 do begin
     if x+dx lt 0 || x+dx gt 14 then continue
     if board[x+dx, y] ne '' then break
     indices->push, (x+dx) + y*15
     directions->push, 0
     minlengths->push, abs(dx)+1
  endfor

  for dy = 0, -7, -1 do begin
     if y+dy lt 0 || y+dy gt 14 then continue
     if board[x, y+dy] ne '' then break
     indices->push, (y+dy)*15 + x

     directions->push, 1
     minlengths->push, abs(dy)+1
  endfor
end


;+
; PURPOSE:
;  This procedure calculates the possible endpoints, directions, and
;  minimum word lengths of possible moves on a scrabble board.
;
; INPUTS:
;  board: A 15x15 string array, listing what words have been played
;  already.
; 
; KEYWORD PARAMETERS:
;  count: On output, will hold the number of insertion points
;
; OUTPUTS:
;  indices: A [2,n] array of end points for possible valid moves
;  directions: A n-element array of directions corresponding to
;              indices. Directions 0-3 indicate that valid words
;              start/end at indices and move to the left, bottom, right,
;              and top, respectively.
;  minlengths: The minimum word length of each index/direction
;              pair. This number guarantees that a tile placement
;              connects to the already-played tiles
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;  July 30 2010: Fixed bug when board is empty
;-
pro get_insertions, board, indices, directions, minlengths, count = count
  
  ;- special rules for the first turn, when the board is empty
  hit = where(board ne '', ct)
  if ct eq 0 then begin
     indices = [7, 7] ;- the center tile
     directions = 0
     count = 1
     minlengths = 2
     return
  endif

  ;- find already-played spaces
  h2 = array_indices(board, hit)
  indices = obj_new('stack')
  directions = obj_new('stack')
  minlengths = obj_new('stack')

  ;- for each played space, add all of the empy adjacent spaces
  for i = 0, ct - 1, 1 do begin
   
     ;- open tile to right of this tile
     if h2[0, i] ne 14 && board[hit[i]+1] eq '' then begin
        x = h2[0,i]+1 & y = h2[1,i]
        _add_squares, board, x, y, indices, directions, minlengths
     endif

     ;- to left
     if h2[0, i] ne 0 && board[hit[i]-1] eq '' then begin
        x = h2[0,i]-1 & y = h2[1,i]
        _add_squares, board, x, y, indices, directions, minlengths
     endif

     ;- above
     if h2[1, i] ne 14 && board[hit[i]+15] eq '' then begin
        x = h2[0,i] & y = h2[1,i]+1
        _add_squares, board, x, y, indices, directions, minlengths
     endif

     ;- below
     if h2[1, i] ne 0 && board[hit[i]-15] eq '' then begin
        x = h2[0,i] & y = h2[1,i]-1
        _add_squares, board, x, y, indices, directions, minlengths
     endif
  endfor

  i = indices->toArray() & d = directions->toArray() & m = minlengths->toArray()
  
  count = indices->getSize()
  obj_destroy, indices & obj_destroy, directions & obj_destroy, minlengths

  ;- for each index / direction pair, take only the shortest minlength
  ind = i[0] & dir = d[0] & min = m[0]
  for j = 1, count - 1, 1 do begin
     bad = where(i[j] eq ind and d[j] eq dir, ct)

     if ct ne 0 then begin
        assert, ct eq 1
        min[bad] <= m[j]
     endif else begin
        ind = [ind, i[j]]
        dir = [dir, d[j]]
        min = [min, m[j]]
     endelse
  endfor

  ;- convert to 2-d index
  indices = array_indices(board, ind)
  directions = dir
  minlengths = min
end
