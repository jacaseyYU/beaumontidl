;- XXX test on row 9, column 8. should have a tile in all directions
pro _add_squares, board, x, y, dir, indices, directions, minlengths
  
  for dx = -7, 7 do begin
     if dx lt 0 and dir eq 0 then continue
     if dx gt 0 and dir eq 2 then continue
     if x+dx lt 0 || x+dx gt 14 then continue
     if board[x+dx, y] ne '' then continue
     indices->push, (x+dx) + y*15
     directions->push, (dx lt 0) ? 0 : 2
     minlengths->push, abs(dx)+1
;     if x+dx  eq 8 and y eq 9 then print, 'Pushing', (dx lt 0 ? 0 : 2), abs(dx)+1
     if dx eq 0 then begin
        indices->push, (x+dx) + y*15
        directions->push, 0
        minlengths->push, 1
     endif        
  endfor

  for dy = -7, 7 do begin
     if dy lt 0 and dir eq 1 then continue
     if dy gt 0 and dir eq 3 then continue
     if y+dy lt 0 || y+dy gt 14 then continue
     if board[x, y+dy] ne '' then continue
     indices->push, (y+dy)*15 + x
     directions->push, (dy lt 0) ? 1 : 3
;     if x  eq 8 and y + dy eq 9 then print, 'Pushing', (dy lt 0 ? 1 : 3), abs(dy)+1
     minlengths->push, abs(dy)+1
     if dy eq 0 then begin
        indices->push, (x) + (y+dy)*15
        directions->push, 1
        minlengths->push, 1
     endif        

  endfor
end


pro find_insertions, board, indices, directions, minlengths, count = count
  hit = where(board ne '', ct)
  if ct eq 0 then begin
     indices = [7, 7] ;- the center tile
     directions = 0
     count = 1
     minlength = 2
     return
  endif

  h2 = array_indices(board, hit)
  indices = obj_new('stack')
  directions = obj_new('stack')
  minlengths = obj_new('stack')
;  message, 'Not functional!'

  for i = 0, ct - 1, 1 do begin
   
     ;- open tile to right of this tile
     if h2[0, i] ne 14 && board[hit[i]+1] eq '' then begin
        x = h2[0,i]+1 & y = h2[1,i]
        _add_squares, board, x, y, 0, indices, directions, minlengths
     endif

     ;- to left
     if h2[0, i] ne 0 && board[hit[i]-1] eq '' then begin
        x = h2[0,i]-1 & y = h2[1,i]
        _add_squares, board, x, y, 2, indices, directions, minlengths
     endif

     ;- above
     if h2[1, i] ne 14 && board[hit[i]+15] eq '' then begin
        x = h2[0,i] & y = h2[1,i]+1
        _add_squares, board, x, y, 1, indices, directions, minlengths
     endif

     ;- below
     if h2[1, i] ne 0 && board[hit[i]-15] eq '' then begin
        x = h2[0,i] & y = h2[1,i]-1
        _add_squares, board, x, y, 3, indices, directions, minlengths
     endif
  endfor

  i = indices->toArray() & d = directions->toArray() & m = minlengths->toArray()
  junk = replicate(0, 15, 15)
  junk[where(board ne '')] = 2
  junk[i] = 1
;  print_board, junk

  count = indices->getSize()
  obj_destroy, indices & obj_destroy, directions & obj_destroy, minlengths

  ;- for each index / direction pair, take only the shortest minlength
  ind = i[0] & dir = d[0] & min = m[0]
  for j = 1, count - 1, 1 do begin
     bad = where(i[j] eq ind and d[j] eq dir, ct)
     if i[j] eq 8 + 9 * 15 then print, d[j], m[j]

     if ct ne 0 then begin
        assert, ct eq 1
        min[bad] <= m[j]
     endif else begin
        ind = [ind, i[j]]
        dir = [dir, d[j]]
        min = [min, m[j]]
     endelse
  endfor
  
  indices = array_indices(board, ind)
  directions = dir
  minlengths = min
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
