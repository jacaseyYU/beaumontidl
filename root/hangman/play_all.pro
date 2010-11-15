pro play_all
  common scrabble, dictionary, letter_Freq, len_ri
  if n_elements(dictionary) eq 0 then read_dictionary

  nturn = intarr(n_elements(dictionary))
  pbar, /new
  for i = 0L, n_elements(dictionary) - 1, 1 do begin
     pbar, 1. * i / n_elements(dictionary)
     play_hangman, dictionary[i], nguess = n, /silent
     nturn[i] = n
  endfor
  pbar, /close
  save, nturn, dictionary, file='play_all.sav'
end
