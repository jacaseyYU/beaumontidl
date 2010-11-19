function xticks, axis, index, value
  return, string(byte(value)+byte('a'))
end

function guess_infogain, partial, excludes, debug = debug, mc = mc
  
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

  ;- compute information gain for every valid guess
  info_gain = replicate(!values.f_infinity, 26)
  todo = where(p_freq eq 0 and e_freq eq 0, todoct)
  done = where(p_freq ne 0 or e_freq ne 0, donect)
  for i = 0, todoct - 1, 1 do begin
     ;- make a mask for each possible word 
     ;- like 'b.a.n' where '.' are not yet revealed
     ;- and letters have been guessed
     letter = todo[i] + a
     info_gain[todo[i]] = expected_uncertainty(partial, excludes, letter, $
                                         bytes)
  endfor
  if keyword_set(debug) then begin
     if n_elements(words) lt 20 then print, words
     help, words
     plot, info_gain, psym = 10, xtickformat='xticks', xticks = 25, $
           xticklen = .5, /nodata
     oplot, info_gain, psym = 10, color = fsc_color('red')
     stop
  endif
  best = min(info_gain, loc)
  result = string(byte(loc[0]) + a)
  assert, size(Result, /tname) eq 'STRING'
  return, result
end


     
