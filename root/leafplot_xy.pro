function leafplot_xy, ptr
  leaves = get_leaves((*ptr).clusters)
  return, dplot_multi_xy(leaves, ptr, /leaf)
end
