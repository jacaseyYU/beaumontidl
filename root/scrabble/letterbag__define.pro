;+
; The letterbag class contains information about the number of each
; tiles for each letter in a scrabble game. It contains functions to
; draw from these letters without replacement.
;
; MODIFICATION HISTORY: July 2010: Written by Chris Beaumont
;-

;+ 
; PURPOSE:
;  Draw n tiles from the letter bag
;
; INPUTS:
;  number: number of tiles to draw. The actual number will be
;  truncated if there are not this many tiles left in the bag.
;
; OUTPUTS:
;  This many tiles, drawn at random from the bag
;-
function letterbag::draw, number
  if self.pos eq 99 then return, ''
  number = (100 - self.pos) < number
  if number eq 0 then return, ''
  result = self.tiles[self.pos : self.pos+number-1]
  self.pos+=number
  return, result
end

function letterbag::isEmpty
  return, self.pos eq 99
end

;+
; PURPOSE:
;  Create the letter bag
;-
function letterbag::init
  
  alphabet = strsplit('a b c d e f g h i j k l m n o p q r s t u v w x y z .', ' ', /extract)
  freq = [9, 2, 2, 4, 12, 2, 3, 2, 9, 1, 1, 4, 2, 6, 8, 2, 1, 6, 4, 6, 4, 2, 2, 1, 2, 1, 2]
  for i = 0, 26 do tiles = append(tiles, replicate(alphabet[i], freq[i]))
  ;- shuffle the tiles
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
