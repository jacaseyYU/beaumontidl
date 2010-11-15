;+
; PURPOSE:
;  Updates the hangman "board" based on a new guess
;
; INPUTS:
;  Partial: The part of the word guessed so far. Unguessed spots are
;  denoted by periods.
;  excludes: A string array of the letters that have been
;  guessed that aren't in the answer
;  guess: The letter to guess
;  answer: The answer
;
; OUTPUTS:
;  A structure with 2 tags: partial and excludes. Both are copies of
;  the inputs, updated to incorporate the new guess
;-
function evaluate_guess, partial, excludes, guess, answer
  
  ;- the byte values of a and z
  a = (byte('a'))[0] & z = (byte('z'))[0]

  ;- turn answer, guess, and partial into byte arrays
  ans = byte(answer)
  g = byte(guess) & g = g[0]
  p = byte(partial)

  ;- which letters of the answer = the guess?
  hit = where(ans eq g, ct)

  if ct eq 0 then begin
     if n_elements(excludes) eq 0 then e = guess $
     else e = [excludes, guess]
     return, {partial: partial, excludes:e}
  endif else begin
     p[hit] = g
     p = string(p)
     return, {partial:p, excludes:n_elements(excludes) eq 0 ? '' : excludes}
  endelse
end
  
