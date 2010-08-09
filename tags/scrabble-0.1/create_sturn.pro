function create_sturn, board, tiles, new_board
  result = {sturn}

  hit = where(board ne new_board, ct)
  h2 = array_indices(board, hit)

  ;- find un-played tiles
  held = tiles
  for i = 0, ct - 1, 1 do begin
     char = byte(new_board[hit[i]])
     if char ge byte('A') and char le byte('Z') then char='.' else char = string(char)
     p = where(held eq char)
     held[p[0]] = '0'
  endfor
  not_played = where(held ne '0', np_ct, complement = played, ncomp = p_ct)
  if np_ct ne 0 then result.held[0:np_ct - 1] = reform(byte(tiles[not_played]))
  if p_ct ne 0 then result.played[0:p_ct-1] = reform(byte(new_board[hit]))

  result.direction = range(h2[0,*]) eq 0 ? 1 : 0
  result.pos = h2[*,0] ;- will either be the top or leftmost played tile

  result.score = score_turn(new_board, new_board ne board)
  
  if np_ct ne 0 then begin
     fragment = strjoin(reform(tiles[not_played]))
     result.hand_strength = hand_strength(fragment)
  endif else result.hand_strength = hand_strength()

  return, result
end

pro test
  board = replicate('', 15, 15)
  b2 = board & b2[0:1,0]=['b','a']
  tiles = ['b','o','b', 'a','n','o']
  s = create_sturn(board, tiles, b2)
  
  print, string(s.played)
  print, string(s.held)
  print, s.pos
  help, s, /struct

  b2[0:6,0] = ['b','a','b','o','o','n','s']
  tiles = [tiles, 's']
  s = create_sturn(board, tiles, b2)
  
  print, string(s.played)
  print, string(s.held)
  print, s.pos
  help, s, /struct

  
end
