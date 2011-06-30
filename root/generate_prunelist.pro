function generate_prunelist, ptr, count, delta = delta, npix = npix

  count = 0
  if n_elements(delta) eq 0 && n_elements(nix) eq 0 then $
     return, -1

  if ~keyword_set(delta) then delta = 0
  if ~keyword_set(npix) then npix = 0

  nst = n_elements((*ptr).height)
  kill = bytarr(nst)
  visited = bytarr(nst)

  l = get_leaves((*ptr).clusters)
  for i = 0, n_elements(l) - 1, 1 do begin
     print, i
     index = l[i]
     h = (*ptr).height[index]
     repeat begin
        if visited[index] then break
        visited[index] = 1B
        lm = leafward_mergers(index, (*ptr).clusters)
        p = merger_partner(index, (*ptr).clusters, merge = m)
        if p eq -1 then break
        np = total( (*ptr).cluster_label_h[lm] )
        de = (h - (*ptr).height[m])
        dokill = np lt npix || de lt delta
        
        kill[index] = dokill
        index = m
     endrep until dokill
     visited[rootward_mergers(l[i], (*ptr).clusters)] = 1B
  endfor
  
  return, where(kill, count)
end
