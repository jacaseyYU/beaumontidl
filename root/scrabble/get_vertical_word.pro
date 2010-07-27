function get_vertical_word, board, pos, single = single
  col_mask = bytarr(15,15) & col_mask[pos[0], *] = 1
  mask = board ne '' and col_mask
  assert, total(mask) ne 0
  if total(mask) eq 1 then $
     return, keyword_set(single) ? board[where(mask)] : ''

  conn = label_region_edge(mask)
  hit = where(conn eq conn[pos[0], pos[1]], ct)
  assert, conn[pos[0], pos[1]] ne 0
  if ct eq 1 then return, keyword_set(single) ? board[hit[0]] : ''
  
  h2 = array_indices(board, hit)
  col = h2[0,0]
  rows = minmax(h2[1,*])
  return, strjoin(reform(board[col, rows[0]:rows[1]]))
end
