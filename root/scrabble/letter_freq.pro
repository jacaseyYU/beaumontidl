;+
; PURPOSE:
;  This function returns a byte array of the number of occurances of
;  each letter in a word.
;
; INPUTS:
;  inword: A word
;
; OUTPUTS:
;  A 26-element byte array. Each element contains the number of times
;  the ith letter appears in inword (i=0=>a). Blanks ('.') are ignored
;
; MODIFICATION HISTORY:
;  July 2010: Written by Chris Beaumont
;-
function letter_freq, inword
  ;- easy, once you realize tyat byte(string) creates a byte array 
  ;- of ascii values
  return, histogram(byte(inword), min = byte('a'), max=byte('z'))
end
