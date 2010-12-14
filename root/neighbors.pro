;+ 
; PURPOSE:
;  This function returns the 1D array indices for the neighbors of a
;  given index in a 2 or 3D array.
;
;  WARNING: This function does NOT implement edge-checking. That is,
;  if the input index is on the edge of the array, bogus values will
;  be calculated and returned. This has been done for speed.
;
; INPUTS:
;  The 1D index of an array
;  array: A 2 or 3D array.
;
; KEYWORD PARAMETERS:
;  all_neighbors: set to return all 8 (2D array) or 26 (3D array)
;  pixels that share a face, edge, side, or corner with the input
;  index. Otherwise, only the 4 (2D) or 6 (3D) neighbors sharing a
;  side/face with index will be returned
;
; OUTPUTS:
;  The 1D indices of the neighbors
;-
function neighbors, ind, array, all_neighbors = all_neighbors
  dx2 = [0,-1,1,0] & dy2=[-1,0,0,1]
  dx2_all = [-1,0,1,-1,1,-1,0,1] & dy2_all = [-1,-1,-1,0,0,1,1,1]
  
  dx3 = [-1,1,0,0,0,0] & dy3=[0,0,-1,1,0,0] & dz3 = [0,0,0,0,-1,1]
  dx3_all = [-1,0,1,-1,0,1,-1,0,1, $
             -1,0,1,-1,1,-1,0,1, $
             -1,0,1,-1,0,1,-1,0,1]
  dy3_all = [-1,-1,-1,0,0,0,1,1,1, $
             -1,-1,-1,0,0,1,1,1, $
             -1,-1,-1,0,0,0,1,1,1]
  dz3_all = [-1,-1,-1,-1,-1,-1,-1,-1,-1, $
             0,0,0,0,0,0,0,0, $
             1,1,1,1,1,1,1,1,1]
  
  all = keyword_set(all_neighbors)
  sz = size(array)
  nd = sz[0]
  
  if nd ne 2 && nd ne 3 then $
     message, 'array must be 2- or 3-dimensional'
  
  
  if nd eq 2 then begin
     if all then return, ind + dx2_all + dy2_all * sz[1]
     return, ind + dx2 + dy2 * sz[1]
  endif else begin
     if all then return, ind + dx3_all + dy3_all * sz[1] + $
                                      dz3_all * sz[1] * sz[2]
     return, ind + dx3 + dy3 * sz[1] + dz3 * sz[1] * sz[2]
  endelse
end
