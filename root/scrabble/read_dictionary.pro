pro read_dictionary
  compile_opt idl2
  common scrabble, dictionary, letter_freq
  dict_file = 'TWL06.txt'
  readcol, '~/pro/scrabble/'+dict_file, dictionary, comment='#', format='a', /silent
  dictionary = strlowcase(dictionary)
  letter_freq = bytarr(26, n_elements(dictionary))
  for i = 0L, n_elements(dictionary) - 1 do letter_freq[*,i] = letter_freq(dictionary[i])
end


