;+
; PURPOSE:
;  Calculates the score for a single word
;
; INPUTS:
;  lettesr: An array of letters spelling out the word
;  letter_bonus: An integer array giving the letter bonuses
;  word_bonus: The word bonuses at each letter
;
; OUTPUTS:
;  The score
;
; PROCEDURE:
;  Note that the tile scores reflect the words with friends version,
;  and not the traditional scrabble version.
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function get_word_score, letters, letter_bonus, word_bonus
  common letter_values, values

  score = values[byte(letters)] * letter_bonus
  score *= product(word_bonus)
  return, total(score)
end
            
