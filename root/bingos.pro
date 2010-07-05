function wordscores, words
  letters = strsplit('a b c d e f g h i j k l m n o p q r s t u v w x y z', $
                    ' ', /extract)
  points = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 3, 8, 4, 10]
  result = replicate(0, n_elements(words))
  for i = 0, 25, 1 do result += points[i] * strmatch(words, '*'+letters[i]+'*')
  return, result
end

pro recursive_find, array, index, result
  file = 'lower'

  sz = n_elements(array)
  if n_elements(result) eq 0 then result = obj_new('stack')
  ;- termination criteria
  if index eq sz then begin
     word = strflat(array, separator='')
     spawn, 'grep "^'+word+'$" '+file, out
     if strlen(out[0]) eq 0 then return
     result->push, out
     return
  endif

  for i = index, sz-1, 1 do begin
     if index eq 0 then print, i

     ;- try a new permutation
     tmp = array[index]
     array[index] = array[i]
     array[i] = tmp

     ;- test for early failure, and for a current word
     regex='"^'+strflat(array[0:index], separator='')
     spawn, 'grep '+regex+'$" '+file, out
     if strlen(out[0]) ne 0 then result->push, out

     if index eq sz-1 then regex+='"' else begin
        a = array[index+1:*]
        hit = where(a eq '.', ct)
        x='['+strflat(a, separator='')+']'
        if ct ne 0 then x='[a-z]'
        x = strflat(replicate(x, sz-1 - index), separator='')
        ;regex += x+'$"'
        regex += '"'
     endelse

     spawn, 'grep -m 1 '+regex+' '+file, out
     if strlen(out[0]) eq 0 then begin
        tmp = array[index]
        array[index] = array[i]
        array[i] = tmp
        continue
     endif

     ;- recurse
     recursive_find, array, index+1, result

     ;- swap back the two tiles
     tmp = array[index]
     array[index] = array[i]
     array[i] = tmp     
  endfor
  return
end

pro bingos, letters

  nletter = strlen(letters)
  array = strarr(nletter)
  for i = 0, nletter-1 do array[i] = strmid(letters, i, 1)

  recursive_find, array, 0, result
  array = result->toArray()
  sz = result->getSize()
  obj_destroy, result
  
  if sz eq 0 then return
  array = array[uniq(array, sort(array))]
  scores = wordscores(array)
  s = reverse(sort(scores))
  print, array[s]
  
end
