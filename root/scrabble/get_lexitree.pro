function get_lexitree
  common scrabble, dictionary, letter_freq, len_ri
  common scrabble_lexitree, lexitree
  if n_elements(dictionary) eq 0 then read_dictionary
  if n_elements(lexitree) eq 0 then begin
     message, /con, 'Creating Lexitree'
     lexitree = obj_new('lexitree')
     lexitree->add_dictionary, dictionary
  endif
  ;- make a copy of lexitree to protect the common block
  result = lexitree
  return, result
end
     
