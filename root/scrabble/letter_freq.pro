function letter_freq, inword
  word = strlowcase(inword[0])
  result = bytarr(26)
  letters = strsplit('a b c d e f g h i j k l m n o p q r s t u v w x y z', ' ' ,/extract)
  for i = 0, strlen(word) - 1 do begin
     letter = strmid(word,i,1)
     if letter eq '.' then continue
     result[byte(letter) - byte('a')]++
  endfor

  return, result
end
