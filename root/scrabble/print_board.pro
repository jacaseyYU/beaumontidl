pro print_board, board
  print, '  |00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|'
  print, strjoin(replicate('-', 48))
  string = size(board, /type) eq 7
  
  fmt = string ?  '(i2.2, "|", 15(a2, "|"))' : '(i2.2, "|", 15(i2, "|"))'
  
  for i = 0, 14, 1 do begin
     print, i, board[*,i], format=fmt
     print, strjoin(replicate('-', 48))
  endfor
end
