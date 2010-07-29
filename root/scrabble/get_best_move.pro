function get_best_move, board, tiles, best_board, new_tiles

  best_board = obj_new('bestlist', 50)
  
  find_insertions, board, indices, directions, minlengths, count = ct
  if ct eq 0 then message, 'cannot find any placements!'

  for i = 0, 14, 1 do begin
     print, 'row/column: ', i
     vertical:
     hit = where(indices[0,*] eq i and (directions eq 1 or directions eq 3), ct2)
     print, 'tiles in column ', i, ' : ', ct2
     if ct2 eq 0 then goto, horizontal
     wordlist = initial_words(board, tiles, [i, 0], 1, count = ct3)
     if ct3 eq 0 then goto, horizontal
     for jj = 0, ct2 - 1, 1 do begin
        get_best_move_fixed, board, tiles, indices[*,hit[jj]], $
                             directions[hit[jj]], minlengths[hit[jj]], $
                             bytarr(15, 15), $
                             best_board, wordlist = wordlist
     endfor

     horizontal:
     hit = where(indices[1,*] eq i and (directions eq 0 or directions eq 2), ct2)
     print, 'tiles in row    ', i, ' : ', ct2
     if ct2 eq 0 then continue
     wordlist = initial_words(board, tiles, [0, i], 0, count = ct3)
     if ct3 eq 0 then continue
     for jj = 0, ct2 - 1, 1 do begin
        get_best_move_fixed, board, tiles, indices[*,hit[jj]], $
                             directions[hit[jj]], minlengths[hit[jj]], $
                             bytarr(15, 15), $
                             best_board, wordlist = wordlist
     
     endfor
  endfor

  b = best_board->fetch_best(score = best_score)
  ii = 0
  print_board, best_board->fetch(ii++, score = s) & print, s
  stop
  obj_destroy, best_board
  best_board = b

  ;- find which tiles were played, and remove them
  new_tiles = tiles
  good = where(board ne best_board, ct)
  if ct eq 0 then return, 0
  played = best_board[good]
  new_tiles = intersection(tiles, played, /disjoint)
  stop

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

  board = replicate('', 15, 15)
  board = [['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-1
           ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-2
           ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-3
           ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-4
           ['', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-5
           ['', '', '', '', '', '', '', '', '','w','i','t','t','y', ''], $ ;-6
           ['', '', '', '', '', '', '', '', '','i', '', '', '', '', ''], $ ;-7
           ['', '', '', '', '', '','p','o','u','c','h','e','d', '', ''], $ ;-8
           ['', '', '', '', '', '', '', '', '','k','i','f', '', '', ''], $ ;-9
           ['', '', '', '', '','g', '', '','h','e', '', '', '', '', ''], $ ;-10
           ['', '', '', '', '','i', '', '','o','r', '', '', '', '', ''], $ ;-11
           ['', '', '', '', '','l','e','x','e','s', '', '', '', '', ''], $ ;-12
           ['', '', '', '', '','l', '', '', '', '', '', '', '', '', ''], $ ;-13
           ['', '', '', '', '','i', '', '', '', '', '', '', '', '', ''], $ ;-14
           ['', '', '','b','e','e','f', '', '', '', '', '', '', '', '']]   ;-15

  print_board, board
  letters=['r','e','t','r','d','a,','.']
;  b2 = board & b2[10:11,8]=['a','f']
;  print_board, b2
;  new = (board ne b2)
;  print, score_turn(b2, new, replicate(0, 15, 15),/debug)
;  return
  score = get_best_move(board, letters, new_board)
  return
  
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
