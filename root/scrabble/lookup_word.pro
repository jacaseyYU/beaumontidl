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

  hit = where(dictionary eq word, ct)
  single = ct eq 1

 
  if n_elements(remainder) ne 0 then begin
     regex = '('
     for i = 0, n_elements(remainder)-2 do regex+=remainder[i]+'|'
     regex+=remainder[n_elements(remainder)-1]
     regex+=')'
     regex = '^'+regex+'*'+word+regex+'*$'
  endif else regex = '^'+word+'$'
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
  
