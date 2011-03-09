pro cloudviz_release

  x = finddep_all('dendroviz.pro')
  
  s = sort(x.func)

  u = x[uniq(x.source, sort(x.source))].source
 

  print, x[s], format='(a25, 5x, a25)'
  print, '------------------------'
  print, u, format='(a)'
end
