function label_region_edge, board
  pad = padboard(board)
  result = label_region(pad)
  return, result[1:15, 1:15]
end
  
