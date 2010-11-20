pro compare_methods, method1, method2, word = word, winner = winner
  
  if n_elements(method1) eq 0 then method1='guess_infogain'
  if n_elements(method2) eq 0 then method2='guess_infogain_2';'guess_human'

  if n_elements(word) eq 0 then begin
     common scrabble, dictionary, letter_freq, len_ri
     if n_elements(dictionary) eq 0 then read_dictionary
     
     word = floor(randomu(seed) * n_elements(dictionary))
     word = dictionary[word]
  endif

  play_hangman, word, nguess = ng, guessfunc = method1
  play_hangman, word, nguess = ng2, guessfunc = method2

  print, ng, ng2, format='("Final score: ", i2, " to ", i2)'
  
  if ng2 lt ng then begin
     print, method2+' wins'
     winner = 2
  endif else if ng lt ng2 then begin
     print, method1+' wins'
     winner = 1
  endif else begin
     print, 'tie'
     winner = 0
  endelse
end

pro driver

  ngame = 100
  n0 = 0 & n1 = 0
  for i = 0, ngame - 1 do begin
     compare_methods, winner = w
     if w eq 1 then n0++ 
     if w eq 2 then n1++
  endfor
  print, n0, n1
end
