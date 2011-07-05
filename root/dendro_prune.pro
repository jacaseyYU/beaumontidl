;+
; PURPOSE:
;  This function prunes a dendrogram, merging the requested branches
;  into other structures. The dendrogram is then re-indexed, such that
;  dendrogram ids run from 0-(nst-1), and the leaf ids run from
;  0-(nleaf)-1.
;
; INPUTS:
;  ptr: A pointer to a cloudviz-style dendrogram structure
;  node_list: The nodes to prune. 
;
; OUTPUTS:
;  A new cloudviz-style dendrogram, with the requested nodes pruned
;
; MODIFICATION HISTORY:
;  June 2011: Written by Chris Beaumont
;-

;-
; create a new dendrogram pointer from a repoint array and merge list
;-
function _new_ptr, ptr, repoint, merge_list


  ;- for each new struct, assign tallest height and median xloc
  h = histogram(repoint, min = 0, rev = ri)
  xloc = replicate(0., n_elements(h))
  height = xloc

  nleaf = n_elements(merge_list) / 2 + 1
  for i = 0, n_elements(h) - 1, 1 do begin
     assert, h[i] ne 0
     ind = ri[ri[i] : ri[i+1]-1]
     if i lt nleaf then $
        height[i] = max( (*ptr).height[ind]) $
     else $
        height[i] = min( (*ptr).height[ind] )
  end
     
  xloc = layout_dendrogram(merge_list)

  cl = (*ptr).cluster_label
  for i = 0, n_elements(repoint) - 1, 1 do begin
     if repoint[i] eq i then continue
     ind = substruct(i, ptr, /single, count = ct)
     if ct eq 0 then continue
     cl[ind] = repoint[i]
  endfor
  
  cluster_label_h = histogram(cl, min = 0, max = n_elements(merge_list)+1, $
                              rev = ri)

  result = { value: (*ptr).value, $
             clusters: merge_list, $
             cluster_label: cl, $
             cluster_label_h: cluster_label_h, $
             cluster_label_ri: ri, $
             xlocation: xloc, $
             height: height $
           }             
  return, ptr_new(result, /no_copy)
end


;-
; create a new mergelist, and update repoint
;
; nodes: The structure array describing the dendrogram.
;  The pruned nodes should have id=-1. All of the references within
;  the non-pruned nodes should point to other non-pruned nodes.
;-
function _new_mergelist, nodes, repoint

  ;- first, make sure repoint doesn't require multiple hops
  while ~array_equal(repoint[repoint], repoint) do $
     repoint = repoint[repoint]

  good = where(nodes.id ne -1, nst)

  ;- non-pruned leavs should point to themselves
  assert, total(repoint[good] ne good) eq 0

  leaves = where(nodes.id ne -1 and nodes.left eq -1, lct)
  branches = where(nodes.id ne -1 and nodes.left ne -1)

  ;- new_ids will form a proper dendrogram sequence,
  ;- with leaves occupying the first nleaf ids,
  ;- and the branches occupying the final nbranch ids
  new_id = repoint * 0 - 1
  new_id[nodes[leaves].id] = indgen(lct)

  ;- make sure number of non-pruned leaves
  ;- consistent with non-pruned branches
  assert, 2 * lct - 1 eq nst
  result = intarr(2, lct - 1)

  q = nodes[branches]
  ;s = reverse(bsort(q.value))
  ;q = q[s]
  
  top = lct
  ;- visit branches in descending order
  ;- height = merge point
  for i = 0, n_elements(q) - 1, 1 do begin
     node = q[i]
     print, node.id
     new_id[node.id] = top

     ;- left and right (leafward) children should be non-pruned
     assert, nodes[node.left].id ne -1, 'Child of a non-pruned node is pruned'
     assert, nodes[node.right].id ne -1, 'Child of non-pruned node is pruned'

     ;- left and right (leafward) children should already have 
     ;- been assigned new ids
     assert, new_id[node.left] ge 0, 'Child of node not yet processed'
     assert, new_id[node.right] ge 0, 'Child of node not yet processed'

     result[*, top - lct] = minmax(new_id[[node.left, node.right]])

     top++
  endfor
  assert, top eq nst
  assert, min(result) eq 0

  redirected = where(repoint ne indgen(n_elements(repoint)))
  assert, max(new_id[redirected]) eq -1
  assert, max(new_id[repoint[redirected]]) ge 0
  new_id[redirected] = new_id[repoint[redirected]]

  assert, min(new_id) eq 0

  repoint = new_id
  return, result
end


;+
; Convert the clusters array into a structure array, explicitly
; listing each branch's relationships
;-
function _create_tree, ptr

  rec = {tree, id:-1, partner:-1, merged:-1, $
         left:-1, right:-1, value:!values.f_nan}

  nst = n_elements((*ptr).height)
  result = replicate(rec, nst)
  result.id = indgen(nst)
  result.value = (*ptr).height

  for i = 0, nst - 1, 1 do begin
     p = merger_partner(i, (*ptr).clusters, merge = m)
     if p eq -1 then continue
     result[i].partner = p
     result[i].merged = m
     result[m].left = min([p, i])
     result[m].right = max([p, i])
     if result[m].value gt min(result[[p,i]].value) then $
        message, 'Bad tree: Merger brighter than leafwards: ' + $
                 string(i, m, p, format='(i0, ", ", i0, ", ", i0)')
  endfor
  return, result
end

function dendro_prune, ptr, prune_list
  if n_params() ne 2 then begin
     print, 'calling sequence:'
     print, 'result = dendro_prune(ptr, prune_list)'
     return, ptr_new()
  end
  np = n_elements(prune_list)
  nst = n_elements((*ptr).height)
  
  if min(prune_list, max=hi) lt 0 || hi ge nst then $
     message, 'Elements of prunelist out of range'
  
  repoint = indgen(nst)
  nodes = _create_tree(ptr)

  prune_list = prune_list[sort(prune_list)]
  for i = 0, np-1, 1 do begin
     id = prune_list[i]
     partner = nodes[id].partner
     merged = nodes[id].merged

     if partner eq -1 then $
        message, 'Cannot prune the root'

     l1 = leafward_mergers(id, (*ptr).clusters)
     
     repoint[l1] = merged
     repoint[partner] = merged

     nodes[merged].left = nodes[partner].left
     nodes[merged].right = nodes[partner].right

     if nodes[partner].left ne -1 then begin
        nodes[nodes[partner].left].merged = merged
        nodes[nodes[partner].right].merged = merged
     endif

     nodes[l1].id = -1
     nodes[partner].id = -1
  endfor
  merge_list = _new_mergelist(nodes, repoint)
  return, _new_ptr(ptr, repoint, merge_list)
end
     
