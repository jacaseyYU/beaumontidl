;+
; PURPOSE:
;  Prints the board to the terminal in a readable format
;
; INPUTS:
;  board: A string or numeric board to print. 15x15 array
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
pro print_board, board
  
  ;- format code depends on data type
  string = size(board, /type) eq 7
  fmt = string ?  '(i2.2, "|", 15(a2, "|"), i2.2)' : '(i2.2, "|", 15(i2, "|"), i2.2)'
  
  print, '  |00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|'
  print, strjoin(replicate('-', 51))
  
  for i = 0, 14, 1 do begin
     print, i, board[*,i],  i, format=fmt
     if (i+1) mod 5 eq 0 then print, strjoin(replicate('-', 51))
  endfor
end
