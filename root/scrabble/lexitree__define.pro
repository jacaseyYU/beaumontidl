function lexitree::get_child, letter, bad = bad, $
                              blank_options = blank_options, count = count

  ;if size(letter, /type) ne 7 || strlen(letter) ne 1 then $
  ;   message, 'Provided letter must be a byte, or a single character'

  ;- blank letter gest special treatment
  if letter eq '.' then begin
     hit = where(obj_valid(self.children), ct)
     bad = 1 & count = ct
     if ct eq 0 then return, obj_new()
     bad = 0
     letters=strsplit('A B C D E F G H I J K L M N O P Q R S T U V W X Y Z', ' ', /extract)
     blank_options = letters[hit]
     return, self.children[hit]
  endif
  blank_options = strlowcase(letter)
  index = byte(blank_options) - 97B ;- 97B ='a'
  result = self.children[index[0]]
  bad = ~obj_valid(result)
  count = ~bad
  return, self.children[index]
end
  
function lexitree::is_word
  return, self.isWord
end

function lexitree::get_word
  return, self.word
end

pro lexitree::add_dictionary, dictionary
  for i = 0L, n_elements(dictionary) - 1 do self->add_word, dictionary[i]
end

pro lexitree::add_word, inword
  ;- turn inword into a byte array
  offset = (byte('a'))[0]
  word = byte(strlowcase(inword)) - offset
  
  ;- insert into tree
  self->recursive_insert, word, 0
end

pro lexitree::recursive_insert, word, pos
  assert, (pos eq 0 && self.word eq '') || $
     (self.word eq string(word[0:pos-1]+97B))

  ;- base case: end of word
  if pos eq n_elements(word) then begin
     self.isWord = 1
     return
  endif

  ;-create child node if necessary
  if ~obj_valid(self.children[word[pos]]) then begin
     self.children[word[pos]] = obj_new('lexitree', $
                                      word = string(word[0:pos] + 97B))
  endif

  ;- recurse on child node
  self.children[word[pos]]->recursive_insert, word, pos+1
end

function lexitree::init, isWord = isWord, word = word
  if keyword_set(isWord) then self.isWord = 1
  if keyword_set(word) then self.word = word
  return, 1
end

pro lexitree::cleanup
  for i = 0, 25 do if obj_valid(self.children[i]) then obj_destroy, self.children[i]
end

pro lexitree__define
  data = {lexitree, $
          isWord: 0B, $ ;- is this path a word
          word: '', $ $ ;- the path to this node, as a string
          children:objarr(26) $ ;- the children nodes
  }
end

pro test
  common scrabble, dictionary, letter_freq, len_ri
  read_dictionary
  t0 = systime(/seconds)
  lexicon = obj_new('lexitree')
  lexicon->add_dictionary, dictionary
  print, time2string(systime(/seconds) - t0)
  save, lexicon, file='lexitree.sav'
  obj_destroy, lexicon
  help, /heap
end
