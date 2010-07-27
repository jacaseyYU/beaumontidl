function score_word_horizontal, board, new_tiles, blanks, pos, debug = debug

  compile_opt idl2
  common scrabble_board, letters, words
  if n_elements(letters) eq 0 then create_board

  assert, board[pos[0], pos[1]] ne ''
  ;- if only a single letter, then not a word
  if (pos[0] eq 0 || board[pos[0]-1, pos[1]] eq '' ) && $
     (pos[0] eq 14 || board[pos[0]+1, pos[1]] eq '') then return, 0

  row_mask = bytarr(15, 15) & row_mask[*, pos[1]] = 1
  connected = label_region_edge(board ne '' and row_mask)
  assert, connected[pos[0], pos[1]] ne 0

  connected = connected eq connected[pos[0], pos[1]]
  hit = where(connected, ct)
  assert, ct ne 0
  
  h2 = array_indices(board, hit)
  assert, range(h2[1,*]) eq 0
  cols = minmax(h2[0,*])
  row = h2[1,0]

  ls = board[cols[0]:cols[1], row]
  if ~is_word(strjoin(ls)) then return, !values.f_nan

  if total(new_tiles[cols[0]:cols[1], row]) eq 0 then return, 0
  if keyword_set(debug) then print, 'Scoring word '+strjoin(ls)
  letter_bonus = (letters[cols[0]:cols[1], row] * new_tiles[cols[0]:cols[1], row]) > 1
  letter_bonus *= (1 - blanks[cols[0]:cols[1], row])
  word_bonus = (words[cols[0]:cols[1], row] * new_tiles[cols[0]: cols[1], row]) > 1
  if keyword_set(debug) then begin
     print, 'word: '+strjoin(ls)
     print, letter_bonus
     print, word_bonus
  endif
  return, get_word_score(ls, letter_bonus, word_bonus)
end

function score_word_vertical, board, new_tiles, blanks, pos, debug = debug
  compile_opt idl2
  common scrabble_board, letters, words
  if n_elements(letters) eq 0 then create_board

  assert, board[pos[0], pos[1]] ne ''
  ;- if only a single letter, then not a word
  if (pos[1] eq 0 || board[pos[0], pos[1]-1] eq '' ) && $
     (pos[1] eq 14 || board[pos[0], pos[1]+1] eq '') then return, 0

  col_mask = bytarr(15, 15) & col_mask[pos[0], *] = 1
  if total(col_mask and new_tiles) lt 2 then return, 0
  mask = col_mask and board ne ''

  connected = label_region_edge(mask)
  assert, connected[pos[0], pos[1]] ne 0

  connected = connected eq connected[pos[0], pos[1]]
  hit = where(connected, ct)
  assert, ct ne 0
  
  h2 = array_indices(board, hit)
  assert, range(h2[0,*]) eq 0
  rows = minmax(h2[1,*])
  col = h2[0,0]

  if total(new_tiles[col, rows[0]:rows[1]]) eq 0 then return, 0

  ls = reform(board[col, rows[0]:rows[1]])
  if ~is_word(strjoin(reform(ls))) then return, !values.f_nan
  if keyword_set(debug) then print, 'scoring word '+strjoin(ls)

  letter_bonus = (letters[col, rows[0]:rows[1]] * new_tiles[col, rows[0]:rows[1]]) > 1
  letter_bonus *= (1 - blanks[col, rows[0]:rows[1]])
  word_bonus = (words[col, rows[0]:rows[1]] * new_tiles[col, rows[0]:rows[1]]) > 1
  return, get_word_score(ls, letter_bonus, word_bonus)
end


function score_turn, board, new_tiles, blanks, debug = debug
  compile_opt idl2

  hit = where(new_tiles, ct)
  if ct eq 0 then return, 0

  h2 = array_indices(board, hit)
  result = 0

  ;- case 1-- tiles lie along constant row
  if range(h2[1,*]) eq 0 then begin
     
     ;- score horizontal word
     result += score_word_horizontal(board, new_tiles, blanks, h2[*,0], debug = debug)

     ;- score any vertical words
     for i = 0, ct - 1, 1 do $
        result += score_word_vertical(board, new_tiles, blanks, h2[*,i], debug = debug)
  endif else if range(h2[0,*]) eq 0 then begin
     if keyword_set(debug) then print, 'Vertical Word'
     ;- score vertical word
     result += score_word_vertical(board, new_tiles, blanks, h2[*,0], debug = debug)
     if keyword_set(debug) then print, result
     for i = 0, ct - 1, 1 do begin
        if ~new_tiles[h2[0,i], h2[1,i]] then continue
        result += score_word_horizontal(board, new_tiles, blanks, h2[*,i], debug = debug)
        if keyword_set(debug) then print, result
     endfor

  endif else message, 'invalid tile placement'
  return, result
end


pro test
    board = replicate('', 15, 15)
  letters=['a','p','p','l','e']

  ;score = get_best_move(board, letters, new_board)
  board[7:11,7]=['a','p','p','l','e']
  new_board = board
  new_board[8, 8:9]=['o','p']
  new = new_board ne board
  print, score_turn(new_board, new, replicate(0, 15, 15),/debug)
end
