;+
; PURPOSE:
;  This is a trivial extension to label_region, which by default flags
;  the edges to zero. Here, edges can be nonzero
;
; INPUTS:
;  board: a 15x15 mask of integers/bytes/whatever
;
; OUTPUTS:
;  the labeled regions of the mask
;
; MODIFICIATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function label_region_edge, board
  pad = padboard(board)
  result = label_region(pad)
  return, result[1:15, 1:15]
end
  
