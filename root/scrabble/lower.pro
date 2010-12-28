pro lower

  readcol, 'TWL06.txt', words, format='a'

  words = strlowcase(words)

  openw, lun, 'TWL06_lower.txt', /get
  printf, lun, words, format='(a)'
end
