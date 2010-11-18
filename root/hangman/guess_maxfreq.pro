function guess_maxfreq, partial, excludes, debug = debug, mc = mc
  
  a = (byte('a'))[0] & z = (byte('z'))[0]
  dot = (byte('.'))[0]

  p_freq = histogram(byte(partial), min=a, max=z)
  e_freq = n_elements(excludes) ne 0 ? $
           histogram(byte(excludes), min=a, max=z) : $
           replicate(0, 26)

  ;- get the word list
  words = possible_words(partial, excludes, count = wct)
  bytes = byte(words)
  
  ;- only 1 word left. Guess a new letter from that word
  if wct eq 1 then begin
     f = histogram(byte(words[0]), min=a, max=z)
     todo = where(f ne 0 and p_Freq eq 0 and e_freq eq 0, ct)
     result = todo[0]
     result = string(byte(result) + a)
     assert, size(result, /tname) eq 'STRING'
     return, result
  endif

  ;- find which un-guessed letter occurs most frequently
  h = histogram(bytes, min = a, max = z)
  unguessed = where(p_freq eq 0 and e_freq eq 0)
  best = max(h[unguessed], loc)
  return, string(byte(unguessed[loc]) + a)
end


     
