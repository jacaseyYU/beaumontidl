pro scrabble_gui_event
pro scrabble

  tlb = widget_base(row = 1)
  board = widget_draw(tlb, xsize = 800, ysize = 800)

  base = widget_base(tlb, col = 1)
  r1 = widget_base(base, /row)
  r2 = widget_base(base, /row)
  r3 = widget_base(base, /row)
  r4 = widget_base(base, /row)
  
  score1 = widget_label(r1, value= 'Player 1 Score: ')
  score2 = widget_label(r2, value = 'Player 2 Score')
  l = widget_label(r3, value = 'Tiles')
  tiles = widget_text(r3, value='', xsize = 7, /edit)

  game_board = get_test_board()
  info = {wid:board, score1:score1, score2:score2, tiles:tiles, $
          board:game_board}
          
  widget_control, tlb, /realize
end
  
