;+
; PURPOSE:
;  Given a hangman guess and a list of letters known not to be in the
;  answer, this function returns a list of candiate words
;
; INPUTS:
;  Regex: The part of the word guessed so far. Unknown letters are
;  denoted by periods. So 'a..l.' might be regex, if the word is
;  'apple', and 'a' and 'l' have been guessed so far.
;  excludes: A string array of letters that have been guessed,
;  but aren't in the word.
;
; KEYWORD PARAMETERS:
;  count: The number of candidate words.
;
; OUTPUTS:
;  A list of candidate words. A string array. If no words match, -1 is returned.
;-
function possible_words, regex, excludes, count = count
  
  count = 0
  if n_elements(excludes) ne 0 && excludes[0] ne '' then ex = excludes
  nex = n_elements(ex)
  
  a = (byte('a'))[0] & z = (byte('z'))[0]

  ;- first find all words that match the regular expression
  valid = is_word(regex, match = words)
  bytes = byte(words)
  
  ;- get the frequency of each letter in each word
  freq = bytarr(26, n_elements(words))
  for i = 0, n_elements(words)-1, 1 do $
     freq[*,i] = histogram(bytes[*,i], min = a, max = z)
  
  ;- eliminate words containing the excluded letters
  keep = replicate(1B, n_elements(words))
  for i = 0, nex-1, 1 do begin
     keep and= ~strmatch(words, '*'+excludes[i]+'*')
  endfor
  good = where(keep, count)
  if count eq 0 then return, -1

  ;- eliminate words containing extra copies of letters 
  ;- that were already guessed
  freq_regex = histogram(byte(regex), min=a, max=z)
  if max(freq_regex) eq 0 then return, words[good]

  fr = rebin(freq_regex, 26, n_elements(words))
  assert, n_elements(fr) eq n_elements(freq)
  keep and= min(fr eq 0 or (fr eq freq), dim=1)
  good = where(keep, count)
  if count eq 0 then return, -1

  return, words[good]
end

pro test
  v = is_word('an.', match = wordlist)
  regex = 'an.'
  ;- wordlist is ana, and, ane, ani, ant, any
  ;- ana is not valid, since a would already have been guessed

  answer=['and', 'ane', 'ani', 'ant', 'any']
  assert, array_equal(possible_words(regex, excludes), answer)

  assert, array_equal(possible_words(regex, 't'), ['and', 'ane', 'ani', 'any'])
  assert, array_equal(possible_words(regex, ['d', 'e','i', 't', 'y']), -1)

  print, 'all tests passed'
  
end
  
     
  

  
