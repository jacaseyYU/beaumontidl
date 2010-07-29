;+ could extend this further, to trim out words with too many
;occurances of any letter
;-
function initial_words, board, tiles, pos, direction, count = count
  common scrabble, dictionary, letter_freq
  if n_elements(dictionary) eq 0 then read_dictionary

  mask = replicate(0, 15, 15)
  if direction eq 0 or direction eq 2 then mask[*,pos[1]] = 1
  if direction eq 1 or direction eq 3 then mask[pos[0],*] = 1
  hit = where(mask and board ne '', ct)
  

  t = ct eq 0 ? tiles : [tiles, board[hit]]

  ;- new code
  return, winnow_words(strjoin(t), count = count)

  ;- old code
  regex = '^('
  for i = 0, n_elements(t) - 2, 1 do regex += t[i]+'|'
  regex += t[n_elements(t)-1]+')*$'
  result = stregex(dictionary, regex, /boolean, /fold)
  hit = where(result, count)
  if count eq 0 then return, -1 

  return, dictionary[hit]
end


pro test
  board = replicate('', 25, 25)
  tiles=['c','a','t','.']
  t0 = systime(/seconds)
  x=initial_words(board, tiles, [7,7], 0)
  print, systime(/seconds) - t0
  help, x
  t0 = systime(/seconds)
  x=initial_words(board, tiles, [7,7], 0)
  print, systime(/seconds) - t0
  print,x
end
