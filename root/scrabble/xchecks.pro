pro xchecks, board, anchors, x_hor, x_vert
  b = strlowcase(board)
  x_hor = ulonarr(15, 15)
  x_vert = ulonarr(15, 15)
  a = (byte('a'))[0]
  lon_letters = ishft(1UL, indgen(26))
 
  hit = where(anchors, ct)
  if ct eq 0 then return
  h2 = array_indices(board, hit)
 
  for i = 0, ct - 1 do begin
     assert, b[hit[i]] eq ''
     b[hit[i]] = '.'
        
     vword = get_vertical_word(b, h2[*,i])
     hword = get_horizontal_word(b, h2[*,i])

     ;- add horizontal checks
     if vword ne '' && is_word(vword, match=m) then begin
        bloc = strpos(vword, '.')
        letters = strmid(m, bloc, 1)
        or_mask = total(lon_letters[byte(letters) - a], /preserve)
        x_hor[hit[i]] = or_mask
     endif

     ;- add vertical checks
     if hword ne '' && is_word(hword, match=m) then begin
        bloc = strpos(hword, '.')
        letters = strmid(m, bloc, 1)
        or_mask = total(lon_letters[byte(letters) - a], /preserve)
        x_vert[hit[i]] = or_mask        
     endif
     b[hit[i]] = ''
  endfor 
end
  
pro test
  board = get_test_board()
  anchors = get_anchors(board)
  xchecks, board, anchors, xhor, xvert

  a = (byte('a'))[0]
  letters = bindgen(26)+a

  mask = ishft(1UL, indgen(26))
  hit = where(xhor ne 0, ct)
  for i = 0, ct - 1, 1 do begin
     print_board, board
     print, array_indices(board, hit[i])
     print, xhor[hit[i]]
     l_mask = where((xhor[hit[i]] and mask) ne 0)
     print, string(letters[l_mask])
  endfor
end
     
