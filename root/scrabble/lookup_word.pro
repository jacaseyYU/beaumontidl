;+
; PURPOSE:
;  Given a word fragment and a set of remaining letters, this function
;  returns a list of possible valid words
;
; INPUTS:
;  fragment: A string word fragment
;  remainder: A string array of remaining letters
;
; KEYWORD PARAMTERS:
;  single: On output, will be 1 if fragment is a word
;  wordlist: Set to a string array to override the default (very
;            large) dictionary with a more restrictive subset.
;  count: On output, the number of words returned
;
; OUTPUTS:
;  A list of candidate words containing fragment and some combination
;  of the remaining letters. Words eliminated from wordlist (or
;  dictionary) cannot be formed with these inputs. In general, there
;  may be extra words on output that actually are invalid. 
;
; COMMON BLOCK:
;  scrabble: Populated by read_dictionary
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function lookup_word, fragment, $ ;- ordered letter array of word fragment
                      remainder, $ ;- other tiles to use
                      single = single, $ ;- set to 1 fragment itself is a word
                      wordlist = wordlist, $ ;- look for words here instead of dict
                      count = count


  common scrabble, dictionary
  if n_elements(dictionary) eq 0 then read_dictionary

  if n_elements(fragment) gt 1 then $
     word = strjoin(fragment) $
  else word = fragment

  if keyword_set(wordlist) then $
     junk = where(wordlist eq word, ct) $
  else $
     junk = where(dictionary eq word, ct)          

  single = ct eq 1

  ;- make a regular expression from the remaining tiles
  if n_elements(remainder) ne 0 then begin
     regex = '('
     for i = 0, n_elements(remainder)-2 do regex+=remainder[i]+'|'
     regex+=remainder[n_elements(remainder)-1]
     regex+=')'
     regex = '^'+regex+'*'+word+regex+'*$'
  endif else regex = '^'+word+'$'

  ;- choose the dictionary, and run stregex
  if keyword_set(wordlist) then begin
     match = stregex(wordlist, regex, /boolean, /fold)
     count = total(match)
     if count eq 0 then result = -1 else result = wordlist[where(match)]
  endif else begin
     match = stregex(dictionary, regex, /boolean, /fold)
     count = total(match)
     if count eq 0 then result = -1 else result = dictionary[where(match)]
  endelse

  return, result
end
  
