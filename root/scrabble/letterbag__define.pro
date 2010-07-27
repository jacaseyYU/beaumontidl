function letterbag::draw, number
  if self.pos eq 99 then return, ''
  number = (100 - self.pos) < number
  if number eq 0 then return, ''
  result = self.tiles[self.pos : self.pos+number-1]
  self.pos+=number
  return, result
end

function letterbag::init
  alphabet = strsplit('a b c d e f g h i j k l m n o p q r s t u v w x y z', ' ', /extract)
  ;- note that there are really 9 "a"s and 2 blanks
  freq = [11, 2, 2, 4, 12, 2, 3, 2, 9, 1, 1, 4, 2, 6, 8, 2, 1, 6, 4, 6, 4, 2, 2, 1, 2, 1]
  assert, n_elements(freq) eq 26
  assert, total(freq) eq 100
  for i = 0, 25 do tiles = append(tiles, replicate(alphabet[i], freq[i]))
  tiles = tiles[sort(randomu(seed, 100))]
  self.tiles = tiles
  return, 1
end


pro letterbag__define
  data = {letterbag, tiles : strarr(100), pos : 0}
end


pro test
  tiles = obj_new('letterbag')
  for i = 0, 24, 1 do print, tiles->draw(4)
  obj_destroy, tiles
end
