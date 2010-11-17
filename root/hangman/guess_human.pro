function guess_human, partial, excludes

  isDone = 0
  while ~isDone do begin
     result = ''
     read, result, prompt = 'Enter a guess:'
     result = strlowcase(result)
     isDone = size(result, /tname) eq 'STRING' && $
        strlen(result) eq 1 && $
        result ge 'a' && result le 'z' && $
        (n_elements(excludes) eq 0 || total(excludes eq result) eq 0)
  endwhile
  return, result
end
        
