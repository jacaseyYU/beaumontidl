;+
; PURPOSE:
;  This function searches for a word fragment in the dictionary, and
;  returns the subset of words containing this fragment.
;
; INPUTS:
;  fragment: A string word fragment. Either a single string or array
;            of letters.
;
; KEYWORD PARAMTERS:
;  single: On output, will be 1 if fragment itself is a word
;  wordlist: Set to a string array to override the default (very
;            large) dictionary with a more restrictive subset (e.g.,
;            from winnow_words, or previous calls to this function).
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
function lookup_word, fragment, $
                      single = single, $
                      wordlist = wordlist, $
                      count = count


  common scrabble, dictionary, letter_freq, len_ri
  if n_elements(dictionary) eq 0 then read_dictionary

  word = n_elements(fragment) gt 1 ? strjoin(fragment) : fragment

  if keyword_set(single) then single = is_word(word, wordlist = wordlist)

  regex=word

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
  
