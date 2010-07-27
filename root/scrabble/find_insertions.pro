pro find_insertions, board, indices, count = count
  hit = where(board ne '', ct)
  if ct eq 0 then begin
     indices = [7, 7] ;- the center tile
     directions = 0
     count = 1
     return
  endif

  h2 = array_indices(board, hit)

  indices = obj_new('stack')
  for i = 0, ct - 1, 1 do begin
     if h2[0, i] ne 14 && board[hit[i]+1] eq '' then $
        indices->push, hit[i]+1
     if h2[0, i] ne 0 && board[hit[i]-1] eq '' then $
        indices->push, hit[i]-1
     if h2[1, i] ne 14 && board[hit[i]+15] eq '' then $
        indices->push, hit[i]+15
     if h2[1, i] ne 0 && board[hit[i]-15] eq '' then $
        indices->push, hit[i]-15
  endfor

  result = indices->toArray()
  count = indices->getSize()
  obj_destroy, indices & indices = result
  indices = array_indices(board, indices)
end


pro test
  ;- on an empty board, should insert into the center spot
  board = replicate('', 15, 15)
  find_insertions, board, indices, directions, count = ct
  assert, min(indices eq [7,7]) && directions eq 0 && ct eq 1
  print, 'empty board test passed'

  ;- board has a single word. 
  board[7,7] = 'a'
  board[7,8] = 'b'
  find_insertions, board, indices, directions, count = ct
  print, 'indices should be [6,7], [6,8], [7,6], [7,9], [8,7], [8,8]'
  print, indices, format='(2(i2, 1x))'
  print, directions, format='(i1, 1x)'
  print, ct

  ;-words on the edge
  board[*]=''
  board[0]='a'
  find_insertions, board, indices, directions, count = ct
  print, 'indices should be [0,1], [1,0]'
  print, indices, format='(2(i2, 1x))'
  print, directions, format='(i1, 1x)'
  print, ct
end
