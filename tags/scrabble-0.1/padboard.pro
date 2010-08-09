;+
; Creates a 16x16 byte mask, with the input 15x15 byte mask in the
; center. Useful for label_region_edge
;-
function padboard, board
  result = replicate(0B, 17, 17)
  result[1:15, 1:15] = board
  return, result
end
