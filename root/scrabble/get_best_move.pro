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
; KEYWORD PARAMETERS:
;  hand: If set, use the hand strength heuristic when choosing the
;        best move. This heuristic tries to predict the approximate
;        score for the next turn, and safeguards against playing away
;        all of your good tiles (e.g., vowels) in one turn.
;
; struct: On output, contains a sturn struct summarizing the best move
;
; OUTPUTS:
;  A bestlist object, containing the 50 best moves
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_best_move, board, tiles, hand = hand, struct = struct

  ;- find possible insertion points
  get_insertions, board, indices, directions, minlengths, count = ct
  if ct eq 0 then begin
     message, 'cannot find any placements!', /con
     return, !values.f_nan
  endif

  best_board = obj_new('bestlist', 50)
  best_board->add, 0, board

  ;- order insertion points by row/column, and loop
  pbar, 'get best move', /new
  for i = 0, 14, 1 do begin
     pbar, 1. * i / 14.

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
                             best_board, wordlist = wordlist, hand = hand
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
                             best_board, wordlist = wordlist, hand = hand
     
     endfor
  endfor
  pbar, /close

  if arg_present(struct) then begin
     b = best_board->fetch_Best(score = s)
     assert, finite(b[0])
     struct = create_sturn(board, tiles, b)
  endif

  return, best_board
end

;- an example turn
pro test
  
  ;- add a blank
  common scrabble_board, lll, www
  if n_elements(lll) eq 0 then create_board

  ;- track execution time
  profiler, /reset & profiler, /system & profiler

  ;- the blaying board
  board = [[ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '','f', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '','i', '', '', '', '', ''], $ 
           [ '', '', '','q', '', '', '','w','i','r','y', '', '', '', ''], $ ;- 8
           [ '', '','p','u','k','e', '','o', '', '', '', '', '', '', ''], $
           [ '', '', '','i', '','m','a','m','b','o', '', '', '', '', ''], $
           [ '', '', '','t', '', '','h','e', '', '', '', '', '', '', ''], $
           ['b','o','w','e','r', '','a','n', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], $
           [ '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']]

  ;- the hand
  letters=['e','l','.','o','t','e','s']

  ;- the best board
  best = get_best_move(board, letters)
  
  ;- look at the best moves
  for ii = 0, 25, 1 do begin
     b = best->fetch(ii++, score = s) & draw_board, b, score1 = score_turn(b, b ne board), $
        new = (b ne board)
     stop
  endfor

  return

  profiler, /report, data = data, out = out
  s = reverse(sort(data.only_time))
  for i = 0, n_elements(s) - 1, 1 do begin
     hit = (where(strmatch(out, data[s[i]].name+'*')))[0]
     print, out[hit]
     if hit lt n_elements(out)-1 && strmid(out[hit+1], 0, 1) eq ' ' then $
        print, out[hit+1]
  endfor
  print, total(data.only_time), max(data.time)
  plot, total(data[s].only_time, /cumul), psym = -4
end
