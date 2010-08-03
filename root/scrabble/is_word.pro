;XXX hande 1 letter, no length matches better

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
;  wordlist: A string array that, if present, overrides the default
;  dictionary. 
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
function is_word, word, matches = matches, wordlist = wordlist
  if strlen(word) eq 1 then return, 0
  matches = ''

  common scrabble, dictionary, letter_freq, len_ri
  if n_elements(dictionary) eq 0 then read_dictionary
 
  ;- do we have any blanks?
  pos = strpos(word, '.')
  if pos eq -1 then begin
     ;- no - just search for word
     if keyword_set(wordlist) then begin
        ind = value_locate(wordlist, word)
        return, wordlist[[ind]] eq word
     endif else begin
        ind = value_locate(dictionary, word)
        return, dictionary[[ind]] eq word
     endelse
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
     ;if pos1 eq 0 && ~keyword_set(wordlist) $
     ;then d = winnow_words(word) else begin
        if keyword_set(wordlist) then begin
           lo = value_locate(wordlist, first) > 0
           hi = value_locate(wordlist, last) < (n_elements(wordlist) - 1)
           d = wordlist[lo:hi]
        endif else begin
           len = strlen(first)
           d = dictionary[len_ri[len_ri[len] : len_ri[len+1]-1]]
           lo = 0 > value_locate(d, first) < (n_elements(dictionary) - 1)
           hi = 0 > value_locate(d, last) < (n_elements(dictionary) - 1)
           d = d[lo:hi]
        endelse
     ;endelse

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
