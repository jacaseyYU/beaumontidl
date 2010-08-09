pro scrabble_game_event, event
  widget_control, event.top, get_uvalue = state, /no_copy
  widget_control, state.gameboard, get_value=scrabble
  if n_elements(state) eq 0 then stop

  invalidTurn = 0
  if event.id ne state.play then goto, finish
  if state.isDone then goto, finish

  ;- you hit the play button
  ;- is your turn legal?
  invalidTurn = 1

  score = score_turn(scrabble.board, scrabble.board ne state.old_board)
  hit = where(scrabble.board ne state.old_board)

  ;-over-write a previously played tile
  if max(state.old_board[hit] ne '') then goto, finish

  played = strjoin(scrabble.board[hit])
  played = strjoin(played)


  if ~finite(score) then goto, finish
  new_letters = draw_new(state.human_letters, played, state.letterbag, bad = bad)
  ;- human went out
  if new_letters eq '' then begin
     widget_control, scrabble.score1, get_value=v1
     v1 = float(v1)
     widget_control, scrabble.score2, get_value=v2
     v2 = float(v2)
     finish_bonus, '', v1, state.computer_letters, v2
     widget_control, scrabble.score1, set_value=string(v1, format='(i2)')
     widget_control, scrabble.score2, set_value=string(v2, format='(i2)')
     state.isDone = 1
  endif


  ;- did we use valid tiles?
  if bad then goto, finish

  ;- turn was legal. increment score
  invalidTurn = 0
  widget_control, scrabble.score1, get_value=val
  print, val
  widget_control, scrabble.score1, set_value=string(float(val)+score, format='(i0)')
  
  ;- draw new tiles
  state.human_letters = new_letters

  ;- computer plays a turn
  state.old_board = scrabble.board
  print, state.computer_letters
  tiles = strarr(strlen(state.computer_letters))
  for i = 0, n_elements(tiles)-1 do tiles[i] = strmid(state.computer_letters, i, 1)
  best = get_best_move(scrabble.board, tiles)
  new_board = best->fetch_best()
  obj_destroy, best
;  stop
  print_board, new_board
  score = score_turn(new_board, new_board ne state.old_board)

  assert, finite(score)
  widget_control, scrabble.score2, get_value=val
  widget_control, scrabble.score2, set_value=string(float(val)+score, format='(i0)')

  ;- computer draws new tiles
  played = new_board[where(new_board ne state.old_board)]
  played = strjoin(played)
  new_letters = draw_new(state.computer_letters, played, state.letterbag)
  state.computer_letters = new_letters

  ;- computer went out
  if new_letters eq '' then begin
     widget_control, scrabble.score1, get_value=v1
     v1 = float(v1)
     widget_control, scrabble.score2, get_value=v2
     v2 = float(v2)
     finish_bonus, state.human_letters, v1, '', v2
     widget_control, scrabble.score1, set_value=string(v1, format='(i2)')
     widget_control, scrabble.score2, set_value=string(v2, format='(i2)')
     state.isDone = 1
  endif

  ;- update letter display
  widget_control, scrabble.letters, set_value=strupcase(state.human_letters)

  ;- update game boards
  scrabble.board = new_board
  state.old_board = scrabble.board

  finish:
  if invalidTurn then scrabble.board = state.old_board
  widget_control, state.gameboard, set_value=scrabble
  widget_control, event.top, set_uvalue = state, /no_copy
  return
end

pro scrabble_game_cleanup, id
  help, id
  widget_control, id, get_uvalue = state, /no_copy
  obj_destroy, state.letterbag
end

pro scrabble_game

  tlb = widget_base(row=1)
  gameboard = scrabble(tlb)
  play = widget_button(tlb, value='Play', ysize = 4)

  widget_control, gameboard, get_value = state
  old_board = state.board
  widget_control, state.ai, sensitive = 0
  widget_control, state.reset, sensitive=0
  widget_control, state.letters, editable=0
  old = state

  letterbag = obj_new('letterbag')
  computer_letters = strjoin(letterbag->draw(7))
  human_letters = strjoin(letterbag->draw(7))
  widget_control, state.letters, set_value=strupcase(human_letters)

  state={gameboard:gameboard, play:play, letterbag:letterbag, old_board:old_board, $
         computer_letters:computer_letters, human_letters:human_letters, $
        isDone:0B}
  widget_control, tlb, set_uvalue = state, /no_copy
  widget_control, tlb, /realize
  scrabble_redraw, old

  xmanager, 'scrabble_game', tlb, cleanup='scrabble_game_cleanup'
end
  
