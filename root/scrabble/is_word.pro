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
;  August 7 2010: Ignore case of input word. cnb.
;-
function is_word, word, matches = matches, wordlist = wordlist
  if strlen(word) eq 1 then return, 0
  inWord = strlowcase(word)
  matches = ''

  common scrabble, dictionary, letter_freq, len_ri
  if n_elements(dictionary) eq 0 then read_dictionary
 
  ;- do we have any blanks?
  pos = strpos(inWord, '.')
  if pos eq -1 then begin
     ;- no - just search for word
     if keyword_set(wordlist) then begin
        if n_elements(wordlist) eq 1 then $
           return, wordlist[0] eq inWord
        ind = 0 > value_locate(wordlist, inWord) < (n_elements(wordlist)-1)
        return, wordlist[[ind]] eq inWord
     endif else begin
        ind = 0 > value_locate(dictionary, inWord) < (n_elements(dictionary)-1)
        return, dictionary[[ind]] eq inWord
     endelse
  endif else begin

     ;- find the first and last possible position in dictionary
     ;- corresponding to the word with blanks
     first = inWord & last = inWord
     pos1 = pos
     while pos ne -1 do begin
        strput, first, 'a', pos
        strput, last, 'z', pos
        pos = strpos(first, '.')
     endwhile
     
     if keyword_set(wordlist) then begin
        if n_elements(wordlist) eq 1 then d = wordlist else begin
           lo = value_locate(wordlist, first) > 0
           hi = value_locate(wordlist, last) < (n_elements(wordlist) - 1)
           d = wordlist[lo:hi]
        endelse
     endif else begin
        len = strlen(first)
        d = dictionary[len_ri[len_ri[len] : len_ri[len+1]-1]]
        lo = 0 > value_locate(d, first) < (n_elements(dictionary) - 1)
        hi = 0 > value_locate(d, last) < (n_elements(dictionary) - 1)
        d = d[lo:hi]
     endelse
     
     result = stregex(d, '^'+inWord+'$', /fold, /boolean)
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
