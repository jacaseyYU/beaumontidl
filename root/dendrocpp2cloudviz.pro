function dendrocpp2cloudviz, file

  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, ' result = dendrocpp2cloudviz(file)'
     return, !values.f_nan
  endif

  if ~file_test(file) then $
     message, 'File not found: ' + file

  im =mrdfits(file, 0, h,/silent)
  id =mrdfits(file, 1, h,/silent)
  clusters = mrdfits(file, 2, h,/silent)

  sz = size(clusters)
  start = (sz[2]+1)/2
  assert, max(clusters[*, start-1]) eq -1 && min(clusters[*,start]) ge 0
  clusters = clusters[*, (sz[2]+1) / 2 : *]
  nleaf = (sz[2]+1)/2
  heights = fltarr(sz[2])
  h = histogram(id, min = 0, rev = ri, max = 2 * nleaf - 1)

  for i = 0, sz[2] - 1, 1 do begin
     isLeaf = i lt nleaf
     if isLeaf then begin
        assert, h[i] ne 0
        ind = ri[ri[i]:ri[i+1]-1]
        heights[i] = max(im[ind],/nan)
     endif else begin
        if min(h[clusters[*, i-nleaf]]) eq 0 then continue
        j = clusters[0, i-nleaf] & k = clusters[1,i-nleaf]
        in1 = ri[ri[j]:ri[j+1]-1]
        in2 = ri[ri[k]:ri[k+1]-1]
        heights[i] = min([im[in1], im[in2]], /nan)
     endelse
  endfor

  linkDistance = max(heights) - heights
  
  dendrogram_mod, clusters, linkDistance, ov, oc, xlocation = xlocation

  st = {$
       value: im, $
       clusters: clusters, $
       cluster_label:id, $
       cluster_label_h:h, $
       cluster_label_ri:ri, $
       xlocation:xlocation, $
       height:heights}

  result = ptr_new(st, /no_copy)
  return, result
end
       
pro test
  ptr = dendrocpp2cloudviz('~/Documents/workspace/dendro/DEBUG/ppv_big_dendro.fits')
  (*ptr).height = alog10((*ptr).height)
  dendroviz, ptr
end
