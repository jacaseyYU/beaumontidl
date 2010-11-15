function guess_prune2, partial, excludes, wordlist = wordlist

  if keyword_set(wordlist) then wl = wordlist
  a = (byte('a'))[0] & z = (byte('z'))[0]

  words = possible_words(partial, excludes, wordlist = wl, count = wct)
  if wct eq 0 then $
     message, 'No valid words match partial guess'

  freq = bytarr(26, wct)

  for i = 0, wct - 1, 1 do freq[byte(words[i]) - a, i] = 1
  ignore = histogram(byte(partial), min = a, max = z)
  if n_elements(excludes) ne 0 then ignore or= $
     histogram(byte(excludes), min = a, max = z)
     
  fitness = fltarr(26) + !values.f_infinity
  for j = 0, wct - 1, 1 do begin
     if j mod 100 eq 0 then print, j, wct
     hit = where(freq[*,j] and ~ignore, hitct)
     miss = where(~freq[*,j] and ~ignore, missct)
     if missct ne 0 then begin
        nonfinite = where(~finite(fitness[miss]), nfct, complement=fin, ncomp = fct)
        if nfct ne 0 then fitness[miss[nonfinite]] = wct
        if fct ne 0 then fitness[miss[fin]] += wct
     endif
     if hitct eq 0 then continue
     for i = 0, hitct - 1 do begin
        guess = string(byte(hit[i]) + a)
        turn = evaluate_guess(partial, excludes, guess, words[j])
        new = possible_words(turn.partial, turn.excludes, wordlist = words, word_freq = wf, count = ct)
        if ct eq 1 then return, guess
        if ~finite(fitness[hit[i]]) then fitness[hit[i]] = ct else $
           fitness[hit[i]] += ct
     endfor
  endfor
  best = min(fitness, loc, /nan)
  return, string(byte(loc) + a)
end

pro test

  dictionary=['abe', 'gob', 'lob']
  guess='...'
  answer = guess_prune2(guess, excludes, wordlist = dictionary)
  print, answer
  answer = guess_prune2(guess, 'a', wordlist = dictionary)
  print, answer
end
