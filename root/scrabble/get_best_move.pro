function get_best_move, board, tiles, best_board, new_tiles
  
  find_insertions, board, indices, count = ct
  if ct eq 0 then message, 'cannot find any placements!'

  best_board = obj_new('bestlist', 10)
  for i = 0, ct - 1, 1 do begin
     print, i, ct - 1
     wordlist = initial_words(board, tiles, indices[*,i], 0, count = ct2)
     if ct2 eq 0 then stop
     for j = 0, 2, 2 do begin
        if ct2 eq 0 then continue
        get_best_move_fixed, board, tiles, indices[*,i], $
                             j, $
                             bytarr(15, 15), $
                             best_board, wordlist = wordlist
     endfor
     wordlist = initial_words(board, tiles, indices[*,i], 1, count = ct2)
     if ct2 eq 0 then stop
     for j = 1, 3, 2 do begin
        if ct2 eq 0 then continue
        get_best_move_fixed, board, tiles, indices[*,i], $
                             j, $
                             bytarr(15, 15), $
                             best_board, wordlist = wordlist
     endfor
  endfor
  b = best_board->fetch_best(score = best_score)
  obj_destroy, best_board
  best_board = b

  ;- find which tiles were played, and remove them
  new_tiles = tiles
  good = where(board ne best_board, ct)
  if ct eq 0 then return, 0
  played = best_board[good]
  new_tiles = intersection(tiles, played, /disjoint)
     
;  print, 'Best Board:'
;  print_board, best_board
;  print, 'Best Score:'
;  print, best_score
  return, best_score
end


pro test
  board = replicate('', 15, 15)

  score = 0
  nmove = 6
  profiler, /reset & profiler, /system & profiler

  letters = obj_new('letterbag')

  for i = 0, nmove - 1, 1 do begin
     tiles = letters->draw(7)
     score += get_best_move(board, tiles, new_board)
     board = new_board
     print_board, board
     print, score
  endfor
  obj_destroy, letters
  profiler, /report

  return

  ;score = get_best_move(board, letters, new_board)
  board[7:11,7]=['a','p','p','l','e']
  tiles=['o','p', 's']
  score = get_best_move(board, tiles, new_board)

;  new_board[8, 8:9]=['o','p']
;  new = new_board ne board
;  print, score_turn(new_board, new, replicate(0, 15, 15))

  print_board, new_board
end
