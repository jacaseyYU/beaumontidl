pro cloudviz2fits, file, ptr

  v = (*ptr).value

  clusters = (*ptr).clusters
  sz = size(clusters)
  ;- in file format, each leaf has a [-1, -1] clusters entry
  clusters = [[intarr(2, sz[2]+1)-1], [clusters]]

  label = (*ptr).cluster_label

  mkhdr, hdr, v
  mwrfits, v, file, hdr, /create
  sxaddpar, hdr, 'EXTNAME', 'index_map'
  mwrfits, label, file
  sxaddpar, hdr, 'EXTNAME', 'Clusters'
  mwrfits, clusters, file
end
