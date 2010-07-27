function padboard, board
  result = replicate(0B, 17, 17)
  result[1:15, 1:15] = board
  return, result
end
