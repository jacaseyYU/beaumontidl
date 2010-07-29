pro get_best_move_fixed, board, tiles, position, direction, minlength, $
                         new_tiles, $
                         best_board, wordlist = wordlist

  TESTING = 0

  assert, keyword_set(wordlist)
  if ~keyword_set(wordlist) then begin
     wordlist = initial_words(board, tiles, position, direction, count = ct)
     if ct eq 0 then return
  endif

  ntile = n_elements(tiles)
  assert, ntile ge 1

  ;- recursion -- loop through next tile placement
  for i = 0, ntile - 1, 1 do begin
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
     new_tiles = new_tiles or nt
     if TESTING then begin
        print_board, new_board
        print_board, new_tiles
     endif

     if try eq 0 then goto, unset
    
     ;- bad primary fragment?
     primary = get_primary_word(new_board, new_tiles, position, direction)
     if ntile eq 1 then $
        options = lookup_word(primary, junk, count = ct, wordlist = wordlist) $
     else $
        options = lookup_word(primary, tiles[1:*], count = ct, wordlist = wordlist)

     if TESTING then print, primary
     if ct eq 0 then goto, unset

     ;- bad secondary word?
     secondary = get_secondary_words(new_board, new_tiles, position, direction, count = ct)
     for j = 0, ct - 1, 1 do if ~is_word(secondary[j]) then goto, unset
     
     ;- so far so good. is this a valid placement?
     if minlength le 1 && is_word(primary) then begin
        score = score_turn(new_board, new_tiles)
        assert, finite(score)
        best_board->add, score, new_board
     endif
     
     ;- recurse on next tile placement
     if ntile ge 2 then get_best_move_fixed, new_board, tiles[1:*], $
                                             position, direction, minlength-1, $
                                             1 * new_tiles, best_board, wordlist = options

     ;- unplace the tile, restore original tile order
     unset:
     new_tiles = new_tiles and not nt
     tmp = tiles[0]
     tiles[0] = tiles[i]
     tiles[i] = tmp
  endfor 
  return
end


