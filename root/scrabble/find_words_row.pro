pro extend_left, row, tiles, pos, checks, maxlen, root, bestlist
  ;- trivial case 1: At left edge. Left is blank
  if pos eq 0 then begin
     extend_right, row, tiles, pos, checks, maxlen, root, bestlist, ''
     return
  endif
  ;- trivial case 2: tiles to left are occupied
  if row[pos-1] ne '' then begin
     r = label_region([0, row ne '', 0])
     asert, r[pos] ne 0
     mask = where(r eq r[pos])
     left = strjoin(row[mask-1])
     extend_right, row, tiles, pos, checks, maxlen, root, bestlist, ''
  endif

  ;- trivial case 3 -- try empty left string
  extend_right, row, tiles, pos, checks, maxlen, root, bestlist, ''

  ;- non trivial case. generate all possible word prefixes 
  ;- from our hand, and extend right
  children = root->get_child('.', count = ct)
  for i = 0, ct - 1, 1 do begin
     

pro find_words_row, row, tiles, anchors, checks, bestlist
  nan = n_elements(anchors)
  maxlen = anchors - shift(anchors, 1) - 1
  maxlen[0] = (anchors[0] - 1) > 0
  root = get_lexitree()
  for i = 0, nan - 1, 1 do begin
     extend_left, row, tiles, anchors[i], checks, maxlen, root, bestlist
  endfor
end
