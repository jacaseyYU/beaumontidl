;+
; PURPOSE:
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; MODIFICATION HISTORY:
;  2010-07-29: Created by Chris Beaumont
;-
function hand_strength, tiles
  compile_opt idl2
  common hand_hash, hash
  common letter_values, values
  if n_elements(values) eq 0 then letter_values
  if n_elements(hash) eq 0 then hash = obj_new('hashtable')

  ;- create a hash key
  key = n_elements(tiles) eq 0 ? '-1' : strjoin(tiles[sort(tiles)])
  if hash->isContained(key) then return, hash->get(key)

  ;- haven't calculated strength for this hand yet.
  ;- want expected hand strength. strategy:
  ;- MC sample new tiles
  ;- find highest scoring word
  ;- repeat until expected score variance < 10%
  ntile = n_elements(tiles)

  hand = strarr(7)
  if ntile gt 0 then hand[0] = tiles
  if ntile lt 7 then hand[ntile:*]='.'
  initial_list = winnow_words(strjoin(hand), count = ct)
  if ct eq 0 then begin
     hash->add, key, 0
     return, 0
  endif

  niter = 0
  mx = 0. & mx2 = 0.
  isDone = 0
  repeat begin
     niter++

     new = draw_tiles(7-ntile)
     if ntile lt 7 then hand[ntile:*]=new
     word = strjoin(hand)
     list = winnow_words(word, count = ct, wordlist = initial_list, wordfreq = wordfreq)
     if ct eq 0 then continue
     
     ;- score the words
     blist = byte(list)
     ess = (byte('s'))[0]
     score = total(values[blist], 1) 
     ;- add in bingo bonus
     score += 35 * (strlen(list) eq 7)
     ;- add in a 30% bonus for words containing an s
     score += score * 1.2 * (total(blist eq ess, 1) gt 0)
     
     ;- find the best score. This is the heuristic strength
     best = max(score, loc)
;     print, list[loc], best
     score = (score[reverse(sort(score))])[3 < (n_elements(score)-1)]

     mx += score & mx2 += score^2
     mu = mx / niter & rms = sqrt((mx2/niter - mu^2) > 0)
;     print, niter, mu, rms /  sqrt(niter)
;     isDone = niter gt 10 && (niter gt 50 || rms /  sqrt(niter) lt 2)
     isDone = niter gt 10 && rms / sqrt(niter) lt .1 * mu
  endrep until isDone

  ;- add result to hash table
  hash->add, key,  mu
  return, mu
end

pro test
  print, hand_strength(['l','a','t','i','n','a','s'])
end
