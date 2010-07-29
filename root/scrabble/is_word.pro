function is_word, word
  common scrabble, dictionary
  if n_elements(dictionary) eq 0 then read_dictionary
  pos = strpos(word, '.')
  if pos eq -1 then begin
     ind = value_locate(dictionary, word)
     return, dictionary[[ind]] eq word
  endif else begin
     first = word & last = word
     while pos ne -1 do begin
        strput, first, 'a', pos
        strput, last, 'z', pos
        pos = strpos(first, '.')
     endwhile
     pos = strpos(word, '.')
     if pos eq 0 then d = winnow_words(word) else begin
        lo = value_locate(dictionary, first)
        hi = value_locate(dictionary, last)
        d = dictionary[lo:hi]
     endelse
     return, max(stregex(d, '^'+word+'$', /fold, /boolean))
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
