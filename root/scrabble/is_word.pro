;+
; PURPOSE:
;  Determines if the given word (possibly including blanks) is a valid
;  word.
;
; INPUTS:
;  word: A string word candidate. periods denote blanks
;
; KEYWORD PARAMETERS:
;  matches: On output, will hold the valid words matched by the input
;  IF that input contains a blank
;
; OUTPUTS:
;  1 if word corresponds to one or more valid words. 0 otherwise
;
; COMMON BLOCKS:
;  scrabble: Populated by read_dictionary. 
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function is_word, word, matches = matches
  matches = ''

  common scrabble, dictionary
  if n_elements(dictionary) eq 0 then read_dictionary
 
  ;- do we have any blanks?
  pos = strpos(word, '.')
  if pos eq -1 then begin
     ;- no - just search for word
     ind = value_locate(dictionary, word)
     return, dictionary[[ind]] eq word
  endif else begin

     ;- find the first and last possible position in dictionary
     ;- corresponding to the word with blanks
     first = word & last = word
     pos1 = pos
     while pos ne -1 do begin
        strput, first, 'a', pos
        strput, last, 'z', pos
        pos = strpos(first, '.')
     endwhile
     
     ;- this bracket of words is too large if the first
     ;- letter is blank. In that case, use winnow_word.
     if pos eq 0 then d = winnow_words(word) else begin
        lo = value_locate(dictionary, first)
        hi = value_locate(dictionary, last)
        d = dictionary[lo:hi]
     endelse

     result = stregex(d, '^'+word+'$', /fold, /boolean)
     hit = where(result, count)
     if count ne 0 then matches = d[hit]
     return, count ne 0
  endelse
end

pro test
  t0 = systime(/seconds)
  for i = 0, 100, 1 do x = is_word('batman')
  print, systime(/seconds) - t0

  t0 = systime(/seconds)
  for i = 0, 100, 1 do x = is_word('.atm.n')
  print, systime(/seconds) - t0
end
