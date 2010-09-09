;+
; PURPOSE:
;  This (recursive) function finds the best possible move to make at a
;  given start (or end) location and direction.
;
; INPUTS:
;  board: The game board. A 15x15 string array
;  tiles: A string array of letters to place
;  position: The reference position -- either the start or end
;            position, depending on direction. A 2 element array
;  direction: 0-3, indicating that letters should be placed moving to
;             the right/bottom/left/top of position
;  minlength: The number of tiles that must be placed in order fo the
;             word to connect with an already-played tile
;  new_tiles: A 15x15 integer array, indicating which tiles have been
;             placed in the current turn. This array is modified
;             during the procedure
;  best_board: A bestlist object to hold the result of the
;  procedure. The score of each bestboard entry corresponds to the
;  turn score, and the data point is the new board.
;
; OUTPUTS:
;  best_board is updated
;
; KEYWORD PARAMETERS:
;  wordlist: A list of words defining the dictionary. This is
;  optional, and read_dictionary will be used to generate a complete
;  dictionary if needed. However, specifying a relevant subset of
;  words can save a lot of time.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;  Aug 7 2010: Changed how blanks are handeled. cnb.
;-

pro get_best_lexitree, board, tiles, position, direction, minlength, $
                       new_tiles, $
                       best_board, lexitree = lexitree, hand = hand
  compile_opt idl2

  TESTING = 0
  if direction ne 0 && direction ne 1 then $
     message, 'This function requires that direction = 0 or 1'

  p = position

  ;- special behavior for first call
  if ~keyword_set(lexitree) then begin
     ;print, 'new '+string(position, format='(2(i0, 2x))')+'  '+strtrim(direction,2)+' '+strtrim(n_elements(tiles),2)
     lexitree = get_lexitree()
     
     ;- postion may be anchored to tiles behind itself. back up
     ;- to incorporate these into fragment checking
     dx = direction eq 0 & dy = direction eq 1
     while p[0]-dx ge 0 && p[1]-dy ge 0 && board[p[0] - dx, p[1] - dy] ne '' do $
           p -= [dx, dy]
  endif else begin
     assert, obj_valid(lexitree)
     ;print, 'recurse ', n_elements(tiles)
  endelse

  ntile = n_elements(tiles)
  assert, ntile ge 1
  ;nt = bytarr(15, 15)

  ;- base case: word is oob
  if min(p, max=hi) lt 0 || hi gt 14 then return

  ;- The current position could be occupied by a tile.
  ;- move along the board until we find a vacancy
  subtree = lexitree
  while board[p[0], p[1]] ne '' do begin
      ;- fatal conflict (base case): We are off the board
     if p[0] lt 0 || p[0] gt 14 || $
        p[1] lt 0 || p[1] gt 14 then return
     
     subtree = subtree->get_child(board[p[0], p[1]])
     
     ;- fatal conflict (base case): The current word is invalid
     if ~obj_valid(subtree) then return
     
     p[0] += (direction eq 0)
     p[1] += (direction eq 1)
  endwhile
  
  tree = subtree
  p_preloop = p
  
  ;- Place a single tile -- try each letter in tiles
  for i = 0, ntile - 1, 1 do begin
     p = p_preloop

     ;- swap tile i and tile 0
     tmp = tiles[0]
     tiles[0] = tiles[i]
     tiles[i] = tmp

     ;- conflict: off the baord
     if p[0] lt 0 || p[0] gt 14 || $
        p[1] lt 0 || p[1] gt 14 then goto, unset

     ;- try to place tile, get possible subtrees
     ;- returns all possible subtree if tile is a blank
     subtree = tree->get_child(tiles[0], bad = bad, count = blank_ct,  $
                                  blank_options = options)
     if tiles[0] ne '.' then assert, options eq tiles[0]

     ;- primary word is invalid
     if bad then goto, unset

     board[p[0], p[1]] = tiles[0]
     assert, new_tiles[p[0], p[1]] eq 0
     new_tiles[p[0], p[1]] = 1
     
     if TESTING then begin
        print_board, board
        print_board, new_tiles
     endif

     ;- loop over possible blank values (only 1 iteration
     ;- if not a blank)
     nsub = n_elements(subtree)
     for bb = 0, nsub - 1, 1 do begin
        p = p_preloop

        ;- place blank on new board
        board[p[0], p[1]] = options[bb]

        ;- this play may have anchored into tiles on the 
        ;- board. Update position until we get a blank spot
        dx = direction eq 0 & dy = direction eq 1
        skip = 0
        while p[0]+dx le 14 && p[1]+dy le 14 && $
           board[p[0]+dx, p[1]+dy] ne '' do begin
           ;print, 'skipping', p
           p += [dx, dy]
           subtree[bb] = subtree[bb]->get_child(board[p[0], p[1]], bad = bad)
           if bad then begin
              skip = 1
              break
           endif
        endwhile
        if skip then continue
                                        
        ;- bad secondary word?
        ;secondary = get_secondary_words(new_board, new_tiles, position, direction, count = ct)
        secondary = get_secondary_words_single(board, p_preloop, $
                                               direction)
        ;skip = 0
        ;for j = 0, ct - 1, 1 do if ~is_word(secondary[j]) then begin
        ;   skip=1
        ;   break
        ;endif
        ;if skip then continue
        if secondary ne '' && ~is_word(secondary) then continue

        ;- so far so good. is this a valid turn?
        if minlength le 1 && subtree[bb]->is_word() then begin
           ;- add this valid move to the bestlist
           score = score_turn(board, new_tiles)
           if keyword_set(hand) then begin
              if n_elements(tiles) eq 1 then score += hand_strength() $
              else score += hand_strength(tiles[1:*])
           endif
           assert, finite(score)
           best_board->add, score, board
        endif
     
        ;- recurse on next tile placement
        new_p = p + [direction eq 0, direction eq 1]
        if ntile ge 2 then get_best_lexitree, board, tiles[1:*], $
                                              new_p, direction, minlength-1, $
                                              new_tiles, best_board, $
                                              lexitree = subtree[bb], $
                                              hand = hand
     endfor                     ;- loop over blank options

     ;- unplace the tile, restore original tile order
     unset:
     p = p_preloop
     new_tiles[p[0], p[1]] = 0
     tmp = tiles[0]
     tiles[0] = tiles[i]
     tiles[i] = tmp
  endfor 
  ;- unplace most recent tile. Restores the original board
  ;- when procedure returns
  board[p[0], p[1]]=''
end


