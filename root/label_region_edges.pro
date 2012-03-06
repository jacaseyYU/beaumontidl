function label_region_edges, array, ulong = ulong, all_neighbors = all_neighbors
  compile_opt idl2
  arr = pad(array)
  r = label_region(arr, ulong=ulong, all_neighbors=all_neighbors)
  return, unpad(r)
end
