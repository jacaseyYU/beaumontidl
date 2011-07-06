pro check_documented

  files = file_search('documented', '*pro', count = ct)

  for i = 0, ct - 1, 1 do begin
     dep = finddep_all(files[i], ct2, /only_source)
     if ct2 eq 0 then continue
     
     in_doc = strmatch(dep.source,   '/Users/beaumont/idl/pro/local/documented*')
     in_local = strmatch(dep.source, '/Users/beaumont/idl/pro/local/*') and ~in_doc
     in_ext = strmatch(dep.source, '/Users/beaumont/idl/pro/external/*')

     if total(in_local) ne 0 then begin
        hit = where(in_local)
        local = append(local, dep[hit].source)
     endif

     if total(in_ext) ne 0 then begin
        hit = where(in_ext)
        external = append(external, dep[hit].source)
     endif
  endfor

  if n_elements(local) ne 0 then begin
     print, 'Local dependencies'
     local = local[uniq(local, sort(local))]
     print, local, format = '("  --  ", a)'
  endif
  
  if n_elements(external) ne 0 then begin
     print, 'External dependencies'
     external = external[uniq(external, sort(external))]
     print, external, format = '("  --  ", a)'
  endif
  
  print, 'Done checking'
end
        
     
