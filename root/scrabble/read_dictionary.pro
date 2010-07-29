;+
; PURPOSE:
;  Reads a dictionary form file, and sets up scrabble common block
;
; COMMON BLOCK
;  scrabble: Contains dictionary (string array) and letter_freq
;  (26-bin histogram for letters in each word)
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
pro read_dictionary
  compile_opt idl2
  common scrabble, dictionary, letter_freq

  ;- options
  ;- TWL06 -- Seems to be the one closest to words with friends
  ;- sowpods -- Used for tournament scrabble. Superset of TWL06.
  ;- words_[small | medum | large] -- not very useful
  dict_file = 'TWL06.txt'
  readcol, '~/pro/scrabble/'+dict_file, dictionary, comment='#', format='a', /silent
  dictionary = strlowcase(dictionary)
  letter_freq = bytarr(26, n_elements(dictionary))
  for i = 0L, n_elements(dictionary) - 1 do letter_freq[*,i] = letter_freq(dictionary[i])
end


