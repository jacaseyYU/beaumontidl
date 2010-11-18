;+
; PURPOSE:
;  Routine to play hangman
;
; INPUTS:
;  word: A word to play with
;
; KEYWORD PARAMETERS:
;  debug: Used for debugging
;  nguess: Set to a variabe to hold the number of total guesses
;  silent: Set to suppress messages
;
; EXAMPLE:
;  IDL> play_hangman, 'apple'
;  Round  1 Guess: a Partial Solution: .a.
;  Round  2 Guess: t Partial Solution: .at
;  Round  3 Guess: b Partial Solution: .at
;  Round  4 Guess: c Partial Solution: cat
;  Finished. Wrong guesses:b
;  Total wrong guesses:            1
;-
pro play_hangman, word, debug = debug, $
                  nguess = nguess, silent = silent, $
                  guessfunc = guessfunc

  compile_opt idl2

  if n_elements(word) eq 0 then word = 'apple'

  ;- make sure this is a dictionary word
  if ~is_word(word) then begin
     print, 'Word not recognized: ', word
     return
  end

  partial = byte(word)
  partial[*] = byte('.')
  partial = string(partial)

  isDone = 0
  nguess = 0
  fmt = '("Round ", i2, " Guess: ", a, " Partial Solution: ", a)'
  print, 'Starting game: '+partial
  while ~isDone do begin
     nguess++
     
     ;- guess a new letter
     ;- specific guessing algorithm goes here
     if keyword_set(guessfunc) then $
        guess = call_function(guessfunc, partial, excludes) $
     else $
        guess = guess_infogain(partial, excludes, debug = debug)

     if size(guess, /tname) ne 'STRING' then stop

     ;- update partial and excludes based on guess
     update = evaluate_guess(partial, excludes, guess, word)
     partial = update.partial
     if ~array_equal(update.excludes, '') then $
        excludes = update.excludes

     ;- have we guessed all the letters?
     isDone = partial eq word
     poss = possible_words(partial, excludes, count = ct)
     isDone or= (ct eq 1)

     ;- print some output
     if ~keyword_set(silent) then $
        print, nguess, guess, partial, format=fmt
  endwhile

  ;- we're done. Print a summary and finish
  if n_elements(excludes) eq 0 then excludes=' None'
  if ~keyword_set(silent) then begin
     print, 'Finished. '+word
     print, 'Wrong guesses: ', excludes
     print, 'Total wrong guesses: ', n_elements(excludes)
  endif
  
end

  
