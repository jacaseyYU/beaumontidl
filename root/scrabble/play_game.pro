pro play_game, hand = hand
  profiler, /reset & profiler, /system & profiler

  letters = obj_new('letterbag')
  board = replicate('', 15, 15)

  p1 = replicate({sturn}, 50)
  p2 = replicate({sturn}, 50)
  isDone = 0
  turn = 0
  p1_letters = letters->draw(7)
  p2_letters = letters->draw(7)
  while ~isDone do begin
     best = get_best_move(board, p1_letters, struct = s, hand = hand)
     p1[turn] = s
     board = best->fetch_best(score = s1)
     assert, size(board, /n_dim) eq 2
     obj_destroy, best

     best = get_best_move(board, p2_letters, struct = s)
     p2[turn] = s
     board = best->fetch_best(score = s2)
     assert, size(board, /n_dim) eq 2
     obj_destroy, best

;     print_board, board
;     print, total(p1.score), total(p2.score), turn

     ;- draw new tiles
     held = p1[turn].held
     hit = where(held ne 0, nheld, ncomp = ndraw)
     if nheld ne 0 then held = string(reform(held[hit], 1, nheld)) $
     else junk = temporary(held)
     if ndraw ne 0 then begin
        draw = letters->draw(ndraw)
     endif
     if nheld ne 0 || n_elements(draw) ne 0 then p1_letters = append(held, draw) $
     else isDone = 1
     hit = where(p1_letters ne '', ct)
     if ct ne 0 then p1_letters = p1_letters[hit] else isDone = 1

     assert, size(p1_letters, /tname) eq 'STRING' && n_elements(p1_letters) le 7

     held = p2[turn].held
     hit = where(held ne 0, nheld, ncomp = ndraw)
     if nheld ne 0 then held =  string(reform(held[hit], 1, nheld)) $
     else junk = temporary(held)

     if ndraw ne 0 then begin
        draw = letters->draw(ndraw)
     endif
     if nheld ne 0 || n_elements(draw) ne 0 then p2_letters = append(held, draw) $
     else isDone = 1
     hit = where(p2_letters ne '', ct)
     if ct ne 0 then p2_letters = p2_letters[hit] else isDone = 1

     assert, size(p2_letters, /tname) eq 'STRING' && n_elements(p2_letters) le 7

     turn++

     draw_board, board, hand1 = p1_letters, hand2 = p2_letters, $
                 score1 = total(p1.score), score2 = total(p2.score)
;     stop
  endwhile
  ;- save results
  files = file_search('saved_games/*.sav', count = ct)
  char = keyword_set(hand) ? '_H':''
  outname = 'saved_games/'+string(ct, format='(i3.3)')+char+'.sav'
  profiler, /report, data = data
  profiler, /report
  save, p1, p2, data, file=outname

end
     
  
  
