pro current_reassign, current, old, new        
  hit = where(current eq old, ct)
  if ct eq 0 then return
  current[hit] = new
end
  
function mergetree, data, kernels, all_neighbors = all_neighbors
  type = size(data, /type)
  if type ne 4 && type ne 5 then $
     message, 'Data must be of type FLOAT or DOUBLE'

  sz = size(data)
  nd = sz[0]
  nk = n_elements(kernels)
  nst = 2 * nk - 1
  
  creation = intarr(2, nst) - 1
  destruction = intarr(nst) - 1
  current = indgen(nst)
  npix = lonarr(nst)
  height = fltarr(nst)
  height[0:nk-1] = data[kernels]

  hi_id = nk-1
  id = fix(data)*0-1
  id_insert = id
  
  ;- Flag edges as NAN (not computed here)
  border = border_indices(data, 1)
  border_val = data[border]
  data[border] = !values.f_nan

  node={index:0L, parent:0, value:0.}
  ks = replicate(node, nk)
  ks.index = kernels
  ks.parent = indgen(nk)
  ks.value = data[kernels]
  q = obj_new('maxheap', ks)

  id_insert[ks.index] = ks.parent
  t0 = systime(/seconds)
  while ~q->isEmpty() do begin
     assert, array_equal(current[current], current)
     top = q->delete()
     top_id = current[top.parent]
     assert, current[top_id] eq top_id
     top_ind = top.index
     if id[top_ind] eq -1 then begin
        ;- pixel is unassigned. Add it to top_id
        id[top_ind] = top_id
        npix[top_id]++

        ;- add neighbors to queue
        n = neighbors(top_ind, data, all_neighbors = all_neighbors)
        nn = n_elements(n)
        nodes = replicate(node, nn)
        nodes.index = n
        nodes.value = data[n]
        nodes.parent = top_id
        tmp = id_insert[nodes.index]
        include = finite(nodes.value) and $
                  (tmp eq -1 or current[tmp] ne nodes.parent)
        for i = 0, nn-1 do begin
           if ~include[i] then continue
           q->insert, nodes[i]
           id_insert[nodes[i].index] = nodes[i].parent
        endfor

     endif else if current[id[top_ind]] ne top_id then begin
        ;- found a merger of 2 structs
        v1 = top_id
        v2 = current[id[top_ind]]
        hi_id++
        print, 'critical', v1, v2, hi_id
        print, 1. * q->getSize() / n_elements(data), total(npix) / (systime(/seconds) - t0)
        destruction[v1] = hi_id & destruction[v2] = hi_id
        creation[*, hi_id] = [v1, v2]
        oldc = current
        current_reassign, current, v1, hi_id
        current_reassign, current, v2, hi_id
        assert, array_equal(current[current], current)
        height[hi_id] = data[top_ind]
     endif
  endwhile

  data[border] = border_val

  ;- decide what to return to user
  obj_destroy, q
  return, id
end

pro test
  data = [[.00, .00, .00, .00, .00, .00, .00, .00], $
          [.00, .20, .30, .12, .11, .19, .15, .00], $
          [.00, .32, .50, .30, .20, .40, .20, .00], $
          [.00, .30, .31, .32, .35, .39, .35, .00], $
          [.00, .60, .90, .70, .80, .70, .60, .00], $
          [.00, .50, .60, .51, .53, .52, .35, .00], $
          [.00, .15, .13, .70, .55, .60, .35, .00], $
          [.00, .30, .12, .23, .33, .43, .53, .00], $
          [.00, .00, .00, .00, .00, .00, .00, .00]]

  data = float(data)
  kernels = cnb_alllocmax(data, friends = 1)
  print, kernels
  print, mergetree(data, kernels)
end
