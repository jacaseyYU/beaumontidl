function terminal_nodes, id, nodes, count = count
  count = 0
  hit = where(id ne -1, ct)
  if ct eq 0 then return, -1

  id = id[hit]
  for i = 0, n_elements(id) -1 do begin
     while nodes[id[i]].destroyed ne -1 do begin
        assert, nodes[id[i]].destroyed gt id[i]
        id[i] = nodes[id[i]].destroyed
     endwhile
  endfor
  
  result = id[uniq(id, sort(id))]
  count = n_elements(result)
  return, result
end
