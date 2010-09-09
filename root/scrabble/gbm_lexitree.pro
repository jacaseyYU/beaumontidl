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
function gbm_lexitree, board, tiles, hand = hand, struct = struct

  ;- find possible insertion points
  get_insertions, board, indices, directions, minlengths, count = ct
  assert, ct eq n_elements(minlengths)
  if ct eq 0 then begin
     message, 'cannot find any placements!', /con
     return, !values.f_nan
  endif

  best_board = obj_new('bestlist', 50)
  pbar, 'get best move lexitree', /new

  for i = 0, ct - 1, 1 do begin
     pbar, 1. * i / ct
     get_best_lexitree, board, tiles, indices[*, i], $
                        directions[i], minlengths[i], $
                        bytarr(15, 15), best_board, hand = hand
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


  ;- the playing board
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
  letters=['e','l','o','t','e','s','.']

  ;- the best board. Try both strategies
  t0 = systime(/seconds)
  best = get_best_move(board, letters)
  print, time2string(systime(/seconds) - t0)
  t0 = systime(/seconds)
  best2 = gbm_lexitree(board, letters)
  print, time2string(systime(/seconds) - t0)
  for ii = 0, 25, 1 do begin
     b1 = best->fetch(ii, score = s)
     b2 = best2->fetch(ii, score = s2)
     assert, s eq s2
  endfor
  obj_destroy, best
  obj_destroy, best2
  return


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
