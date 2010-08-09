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

pro get_best_move_fixed, board, tiles, position, direction, minlength, $
                         new_tiles, $
                         best_board, wordlist = wordlist, hand = hand
  compile_opt idl2

  TESTING = 0
  
  ;- get a sensible wordlist, if not provided
  if ~keyword_set(wordlist) then begin
     wordlist = initial_words(board, tiles, position, direction, count = ct)
     if ct eq 0 then return
  endif

  ntile = n_elements(tiles)
  assert, ntile ge 1

  ;- Place a single tile -- try each letter in tiles
  for i = 0, ntile - 1, 1 do begin

     ;- swap tile i and tile 0
     tmp = tiles[0]
     tiles[0] = tiles[i]
     tiles[i] = tmp

     ;- try to place this new tile. If there are conflicts, abort.
     ;- possible conflicts:
     ;-  at edge of board -- can't place this tile
     ;-  creates a bogus secondary word
     ;-  creates an impossible primary word fragment

     ;- edge of board?
     try = place_tiles(board, tiles[0], position, $
                       direction, new_board, nt)
     if try eq 0 then goto, unset ;- not at edge
     
     npos = where(nt)
     assert, total(nt) eq 1
     new_tiles = new_tiles or nt
     
     if TESTING then begin
        print_board, new_board
        print_board, new_tiles
     endif
    
     ;- bad primary fragment?
     primary = get_primary_word(new_board, new_tiles, position, direction)
     p_bak = primary
     options = lookup_word(primary, count = ct, wordlist = wordlist, /anchor)
     if TESTING then print, primary

     ;- no valid, sufficiently long words containing the primary fragment
     if ct eq 0 || max(strlen(wordlist)) - strlen(primary) lt (minlength-1) then goto, unset

     ;- have we played a blank?
     bpos = strpos(primary, '.')
     isBlank = bpos ne -1
     if isBlank then begin
        assert, total(new_board eq '.') eq 1
        blank_options = strmid(options, bpos, 1)
        blank_options = blank_options[uniq(blank_options, sort(blank_options))]
        blank_options = strupcase(blank_options)
     endif else blank_options = new_board[npos]

     ;- loop over possible plank values (only 1 iteration
     ;- if not a blank)
     for bb = 0, n_elements(blank_options) - 1, 1 do begin
        assert, blank_options[bb] ne ''
        new_board[npos] = blank_options[bb]
        if isBlank then strput, primary, blank_options[bb], bpos

        ;- bad secondary word?
        secondary = get_secondary_words(new_board, new_tiles, position, direction, count = ct)
        skip = 0
        for j = 0, ct - 1, 1 do if ~is_word(secondary[j]) then skip=1
        if skip then continue
     
        ;- so far so good. is this a valid placement?
        if minlength le 1 && is_word(primary, wordlist = options) then begin
           ;- add this valid move to the bestlist
           score = score_turn(new_board, new_tiles)
           if keyword_set(hand) then begin
              if n_elements(tiles) eq 1 then score += hand_strength() $
              else score += hand_strength(tiles[1:*])
           endif
           assert, finite(score)
           best_board->add, score, new_board
        endif
     
        ;- recurse on next tile placement
        if ntile ge 2 then get_best_move_fixed, new_board, tiles[1:*], $
                                                position, direction, minlength-1, $
                                                1 * new_tiles, best_board, wordlist = options, $
                                                hand = hand
     endfor ;- loop over blank options

     ;- unplace the tile, restore original tile order
     unset:
     new_tiles = new_tiles and not nt
     tmp = tiles[0]
     tiles[0] = tiles[i]
     tiles[i] = tmp
  endfor 
  ;- done
end


