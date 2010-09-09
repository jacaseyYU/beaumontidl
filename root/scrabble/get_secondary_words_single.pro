function get_secondary_words_single, board, pos, direction
  ind = pos[direction]
  row = reform((direction eq 0) ? board[ind,*] : board[*, ind], /over)
  ind = pos[~direction]
  
  reg = label_region([0, row ne '', 0]) 
;  assert, reg[ind+1] ne 0
  hit = where(reg eq reg[ind+1], ct)
  return, ct eq 1 ? '' : strjoin(row[hit-1])
end
  
