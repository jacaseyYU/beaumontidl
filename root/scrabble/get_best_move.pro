;+
; PURPOSE:
;  This function finds the highest-scoring turn, given a scrabble
;  board and set of tiles
;
; INPUTS:
;  board: A 15x15 string array, showing the already played
;         letters. Empty spaces correspond to empty strings
;  tiles: A string array of letter tiles. periods correspond to blanks
;
; OUTPUTS:
;  A bestlist object, containing the 50 best moves
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_best_move, board, tiles

  ;- find possible insertion points
  get_insertions, board, indices, directions, minlengths, count = ct
  if ct eq 0 then begin
     message, 'cannot find any placements!', /con
     return, !values.f_nan
  endif

  best_board = obj_new('bestlist', 50)

  ;- order insertion points by row/column, and loop
  for i = 0, 14, 1 do begin
     
     vertical:
     hit = where(indices[0,*] eq i and (directions eq 1 or directions eq 3), ct2)
     if ct2 eq 0 then goto, horizontal

     ;- the possible words using letters from our hand and column i
     wordlist = initial_words(board, tiles, [i, 0], 1, count = ct3)
     if ct3 eq 0 then goto, horizontal

     for jj = 0, ct2 - 1, 1 do begin
        get_best_move_fixed, board, tiles, indices[*,hit[jj]], $
                             directions[hit[jj]], minlengths[hit[jj]], $
                             bytarr(15, 15), $
                             best_board, wordlist = wordlist
     endfor

     ;- same as vertical, but for row i
     horizontal:
     hit = where(indices[1,*] eq i and (directions eq 0 or directions eq 2), ct2)
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

  return, best_board
end

;- an example turn
pro test
  
  ;- add a blank
  common scrabble_board, lll, www, bbb
  if n_elements(lll) eq 0 then create_board
  bbb[7, 13] = 1 

  ;- track execution time
  profiler, /reset & profiler, /system & profiler

  ;- the blaying board
  board = [[ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-0
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-1
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-2
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-3
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $ ;-4
           [ '', '', '', '', '', '', '', '', '','w','i','t','t','y', ''], $ ;-5
           [ '','c', '', '', '', '', '', '', '','i', '', '', '', '', ''], $ ;-6
           [ '','l', '', '', '', '','p','o','u','c','h','e','d', '', ''], $ ;-7
           ['l','a', '', '', '', '', '', '', '','k','i','f', '', '', ''], $ ;-8
           ['u','m', '', '', '','g', '', '','h','e', '', '', '', '', ''], $ ;-9
           ['n', '', '', '', '','i', '', '','o','r', '', '', '', '', ''], $ ;-10
           ['g', '', '', '', '','l','e','x','e','s', '', '', '', '', ''], $ ;-11
           ['e', '', '', '', '','l', '', '', '', '', '', '', '', '', ''], $ ;-12
           ['d','a','t','a','r','i','e','s', '', '', '', '', '', '', ''], $ ;-13
           [ '', '', '','b','e','e','f', '', '', '', '', '', '', '', '']]   ;-14

  print_board, board
  ;- the hand
  letters=['n','s','t','u','i','o','t']

  ;- the best board
  best = get_best_move(board, letters)
  
  ;- look at the best moves
  ii = 0
  b = best->fetch(ii++, score = s) & print_board, b & print, s, format='("Best score: ", i0)'
  stop
end
