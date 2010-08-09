pro draw_board, board, hand1 = hand1, score1 = score1, hand2 = hand2, score2 = score2, new = new, $
                wid = wid, pstruct = pstruct
  common scrabble_board, letters, words
  common letter_values, values
  if n_elements(letters) eq 0 then create_board
  if n_elements(values) eq 0 then letter_values
  if n_elements(board) eq 0 then board=get_test_board()

  newWin = ~keyword_set(wid)
  wid = newWin ? 0 : wid

  xsz = 1200
  ysz = 800
  pixid = 9

  if newWin then wedit, wid, xsize = xsz, ysize = ysz
  
  window, pixid, xsize = !d.x_size, ysize = !d.y_size, /pix
  erase
;  pos = [.01, .05, .7, .95]
  pos = [.01, .01, .98, .98]
  tvimage, bytarr(15, 15), pos = pos, /keep
  plot, [15, 15], /nodata, xticks = 1, $
        yticks = 1, yminor = 1,  pos = pos, /noerase, xminor = 1, $
        xtickn = [' ', ' '], ytickn = [' ', ' '], xra = [0, 15], yra = [0, 15], $
        /xsty, /ysty, color = fsc_color('charcoal')
  !p.font = 1

  ;- letter bonuses
  hit = where(letters gt 1, ct)
  h2 = array_indices(letters, hit)
  for i = 0, ct - 1, 1 do begin
     x = h2[0, i] & y = 14 - h2[1, i]
     triple = letters[hit[i]] eq 3
     polyfill, [x, x+1, x+1, x], [y, y, y+1, y+1], $
               color = triple ? fsc_color('blue') : $
               fsc_color('skyblue')
  endfor

  ;- word bonuses
  hit = where(words gt 1, ct)
  h2 = array_indices(words, hit)
  for i = 0, ct - 1, 1 do begin
     x = h2[0, i] & y = 14 - h2[1, i]
     triple = words[hit[i]] eq 3
     polyfill, [x, x+1, x+1, x], [y, y, y+1, y+1], $
               color = triple ? fsc_color('crimson') : $
               fsc_color('salmon')
  endfor

  ;- grid
  for i = 1, 14, 1 do begin
     oplot, [0, 15], [i, i], color = fsc_color('charcoal')
     oplot, [i, i], [0, 15], color = fsc_color('charcoal')
  endfor

  ;- fill in letters
  hit = where(board ne '', ct)
  if ct ne 0 then h2 = array_indices(board, hit)
  for i = 0, ct - 1, 1 do begin
     x = h2[0,i] & y = 14-h2[1,i] & letter = board[hit[i]]
     hashcol = keyword_set(new) && new[hit[i]] ? fsc_color('yellow') : fsc_color('charcoal')
     polyfill, [x, x+1, x+1, x], [y, y, y+1, y+1], $
               color = hashcol, /line_fill, spacing = .05, ori = 45, thick = 1.5
     polyfill, [x, x+1, x+1, x], [y, y, y+1, y+1], $
               color = hashcol, $
               /line_fill, spacing = .05, $
               ori = -45, thick = 1.5
     oplot, [x, x+1, x+1, x, x], [y, y, y+1, y+1, y], color = hashcol, thick=3
     xyouts, x+.5, y+.4, letter, color = fsc_color('white'), $
             charsize = 3, charthick = 2, align=.5
     xyouts, x+.95, y+.1, strtrim(values[byte(letter)],2), color = fsc_color('white'), $
             charsize = 1.5, charthick = 1.5, align = 1

  endfor
  drawScore = 0
  if drawScore then begin
  ;- put player letters, scores to right
     xyouts, .7, .8, 'Player 1', /norm, charsize = 5, charthick = 2
     if keyword_set(score1) then xyouts, .85, .8, string(score1, format='(i3)'), $
                                         charsize=  5, charthick = 2, /norm
     if keyword_set(hand1) then begin
        xyouts, .7, .75, strjoin(hand1), charsize = 3, charthick = 1.5, /norm
     endif
     
     xyouts, .7, .6, 'Player 2', /norm, charsize = 5, charthick = 2
     if keyword_set(score2) then xyouts, .85, .6, string(score2, format='(i3)'), $
                                         charsize=  5, charthick = 2, /norm
     if keyword_set(hand2) then begin
        xyouts, .7, .55, strjoin(hand2), charsize = 3, charthick = 1.5, /norm
     endif
  endif

  pstruct = !p
  wset, wid
  device, copy=[0,0, !d.x_size, !d.y_size, 0, 0, pixid]
  wdelete, pixid
end

pro test
  board = get_test_board()
  score1 = 15
  score2 = 30
  hand1 = ['a', 'b', 'c']
  hand2 = ['b', 'a', 'b', 'o', 'o', 'n', 's','g']
  draw_board, board, score1 = score1, score2 = score2, hand1 = hand1, hand2 = hand2
end
