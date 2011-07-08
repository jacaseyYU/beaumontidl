function generate_prunelist, ptr, count, delta = delta, npix = npix

  if n_params() ne 2 then begin
     print, 'calling sequence'
     print, 'result = generate_prunelist(ptr, count, '
     print, '                           (delta = delta, npix = npix)'
     return, !values.f_nan
  endif

  count = 0
  if n_elements(delta) eq 0 && n_elements(npix) eq 0 then $
     return, -1

  if ~keyword_set(delta) then delta = 0
  if ~keyword_set(npix) then npix = 0

  nst = n_elements((*ptr).height)
  kill = bytarr(nst)
  visited = bytarr(nst)

  d_index = obj_new('dendro_index', ptr)

  l = get_leaves((*ptr).clusters)
  for i = 0, n_elements(l) - 1, 1 do begin
     index = l[i]
     h = (*ptr).height[index]
     repeat begin
        if visited[index] then break
        visited[index] = 1B
        lm = d_index->leafward_mergers(index)
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
  obj_destroy, d_index

  return, where(kill, count)
end
