function _layout_tree, clusters

  rec = {id:-1, partner:-1, merged:-1, $
         left:-1, right:-1, x:0., dx:0.}

  nst = n_elements(clusters)+1
  result = replicate(rec, nst)
  result.id = indgen(nst)

  for i = 0, nst - 1, 1 do begin
     p = merger_partner(i, clusters, merge = m)
     if p eq -1 then continue
     result[i].partner = p
     result[i].merged = m
     result[m].left = min([p, i])
     result[m].right = max([p, i])
  endfor
  return, result
end

pro find_width, tree, index
  if index eq -1 then return
  l = tree[index].left
  r = tree[index].right
  find_width, tree, l
  find_width, tree, r

  if l ne -1 then begin
     tree[index].dx = tree[l].dx + tree[r].dx
  endif else begin
     tree[index].dx = 1
  endelse

end

pro find_x, tree, index
  if index eq -1 then return
  if tree[index].left eq -1 then return

  l = tree[index].left
  r = tree[index].right

  tree[l].x = tree[index].x - tree[index].dx/2. + tree[l].dx/2.
  w = tree[l].dx
  tree[r].x = tree[index].x - tree[index].dx/2. + w + tree[r].dx/2.
  find_x, tree, l
  find_x, tree, r
end

function layout_dendrogram, clusters
  tree = _layout_tree(clusters)

  find_width, tree, n_elements(tree)-1
  find_x, tree, n_elements(tree)-1
  return, tree.x - min(tree.x)
end
  
  
