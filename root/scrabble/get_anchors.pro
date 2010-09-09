function get_anchors, board
  result = bytarr(15, 15)
  hit = where(board ne '', ct)
  if ct eq 0 then return, result
  h2 = array_indices(board, hit)
  for i = 0, ct - 1 do begin
     x = h2[0,i] & y = h2[1,i]
     if x gt 0 && board[x-1,y] eq '' then result[x-1,y] = 1
     if x lt 14 && board[x+1, y] eq '' then result[x+1,y] = 1
     if y gt 0 && board[x,y-1] eq '' then result[x,y-1] = 1
     if y lt 14 && board[x, y+1] eq '' then result[x,y+1] = 1
  endfor
  return, result
end

pro test
  
  board = get_test_board()
  print_board, board
  print, ''
  print_board, get_anchors(board)
end
