function define_word, word
  url = 'http://www.google.com/search?q=define:'+word
  page = webget(url)

  text = page.text[n_elements(page.text)-1]
  pos = 0
  pos = strpos(text, '<li>', pos)
  while pos ne -1 do begin
     start = pos+4
     stop = strpos(text, "<", start)
     result = append(result, strmid(text, start, stop - start))
     pos = strpos(text, '<li>', stop)
  endwhile

  return, n_elements(result) eq 0 ? '' : result
end

pro test
  print, define_word('qi')
end
