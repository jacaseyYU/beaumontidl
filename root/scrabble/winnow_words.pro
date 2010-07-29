;+
; PURPOSE:
;  This function finds all words in the default dictionary which
;  consist of permutations of the letters in a given word. It is
;  useful for narrowing down possible words before the first call to
;  get_best_move_fixed. 
;
; INPUTS:
;  word: A string word. Blanks/wildcards are reperesented by '.'
;
; KEYWORD PARAMETERS:
;  count: The number of words returned.
;
; OUTPUTS:
;  An alphabetized list of the words in dictionary which can be formed
;  by rearranging a subset of the letters in word.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function winnow_words, word, count = count
  compile_opt idl2
  common scrabble, dictionary, letter_freq
  if n_elements(dictionary) eq 0 then read_dictionary
  
  n_blank = 0
  p = strpos(word, '.', 0)
  while p ne -1 do begin
     n_blank ++
     p = strpos(word, '.', p+1)
  endwhile

  freq = letter_freq(word)
  off = letter_freq
  for i = 0, 25 do off[i,*] = (off[i,*] - freq[i]) * (off[i,*] ge freq[i])
  off = total(off, 1)

  valid = where(off le n_blank, count)
  if count eq 0 then return, -1 else return, dictionary[valid]
end
