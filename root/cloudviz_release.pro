pro cloudviz_release

  x = finddep_all('dendroviz.pro')
  
  s = sort(x.func)

  u = x[uniq(x.source, sort(x.source))].source
 

;  print, x[s], format='(a25, 5x, a55)'
;  print, '------------------------'
;  print, u, format='(a)'
;  return

  basedir = '~/cloudviz/'
  
  ;- remove old .pro files
  spawn, 'find '+basedir+' -name "*.pro" | xargs rm -f'

  ;- copy files to release directory
  for i = 0, n_elements(u) - 1, 1 do begin
     file = u[i]
     if file eq '' then continue
     if strmatch(file, '/Applications/itt*') then continue
     print, file
     if strmatch(file, '/Users/beaumont/idl/pro/external/dendro_branch/*') then begin
        outf = strmid(file, strlen('/Users/beaumont/idl/pro/external/dendro_branch/'))
        cmd = 'cp '+file + ' '+basedir+'external/dendro/'+outf
;        print, cmd
        spawn, cmd
        continue
     endif
     if strmatch(file, '/Users/beaumont/idl/pro/external/*') then begin
        outf = strmid(file, strlen('/Users/beaumont/idl/pro/external/'))
        cmd = 'cp '+file + ' '+basedir+'external/'+outf
;        print, cmd
        spawn, cmd
        continue
     endif
     outf = strsplit(file, '/', /extract)
     outf = outf[n_elements(outf)-1]
     cmd =  'cp '+file+' '+basedir+'src/'+outf
;     print, cmd
     spawn, cmd
  endfor  

  ;- copy over bmp images
  spawn, 'cp ~/pro/*bmp ~/cloudviz/src/'
  spawn, 'cp ~/pro/dendroviz_example.pro ~/cloudviz/examples/'
end
