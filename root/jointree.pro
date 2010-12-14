function jointree, data, thresh = thresh, map = visited

  sz = size(data)
  ndim = sz[0]
  
  border = border_indices(data, 1)
  borderval = data[border]
  data[border] = -!values.f_infinity

  if n_elements(thresh) eq 0 then thresh = -!values.f_infinity

  hit = where(data gt thresh, ct)
  if ct eq 0 then $
     message, 'No data brighter than threshhold'

  visited = long(data)*0 - 1
  rec = {isLeaf:0B, destroyed:-1L, val:0.}
  nodes = replicate(rec, 1000)

  s = sort(data[hit])
  current_node = -1L

  offsets = neighbor_offsets(data)
  pbar, /new
  for i = ct-1, 0, -1 do begin
     if i mod 25000 eq 0 then pbar, 1. * (ct - i) / ct
     ind = hit[s[i]]
     neighbors = visited[ind + offsets]
     neighbors = terminal_nodes(neighbors, nodes, count = tct)

     new = tct eq 0
     extended = tct eq 1
     joined = tct gt 1
     if new then begin
        current_node++
        if current_node eq n_elements(nodes) then $
           nodes = [nodes, replicate(rec, n_elements(nodes))]
        nodes[current_node].val = data[ind]
        nodes[current_node].isLeaf = 1B
        visited[ind] = current_node
     endif else if extended then begin
        visited[ind] = neighbors
     endif else begin
        current_node++
        if current_node eq n_elements(nodes) then $
           nodes = [nodes, replicate(rec, n_elements(nodes))]
        assert, max(neighbors) lt current_node
        nodes[neighbors].destroyed = current_node
        nodes[current_node].val = data[ind]
        visited[ind] = current_node
     endelse
  endfor
  pbar, /close
  data[border] = borderval
  return, nodes[0:current_node]
end


pro test

  data = [[0, 0, 0, 0, 0, 0], $
          [0, 2, 0, 0, 0, 0], $
          [0, 2, 2, 0, 0, 0], $
          [0, 2, 2, 0, 0, 0], $
          [0, 0, 1, 0, 0, 0], $
          [0, 0, 2, 2, 0, 0], $
          [0, 0, 0, 0, 0, 0]]
  data = float(data)
  print, jointree(data, thresh = .5, map = map)
  print, data
  print,'map'
  print, fix(map)

  sz = arrgen(5., 300., nstep = 10)
  num = fltarr(10)
  for i = 0, 9, 1 do begin
     print, i
     map = randomu(seed, sz[i], sz[i], sz[i])
     j = jointree(map, thresh = 0)
     num[i] = n_elements(j)
  endfor
  plot, sz^3, num/sz^3, /xlog, /ylog, psym = -4
end
