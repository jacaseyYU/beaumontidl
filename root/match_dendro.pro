;+
; PURPOSE:
;  This function attempts to cross-match dendrogram structures in a
;  PPP and PPV cube, given knowledge of how PPP structures project
;  into PPV space.
;
; INPUTS:
;  ppp: A dendrogram pointer for the ppp cube
;  ppv: A dendrogram pointer for the ppv cube
;  vcube: The radial velocity for each pixel in the original ppp
;         cube. Must be the same size as the cube used to generate
;         ppp. 
;  vcen: The velocity of each channel along the third axis of the PPV
;        cube. 
;
; OUTPUTS:
;  An array of structures, one for each PPV blob. These structures
;  have the following tags:
;    id: The PPV id
;    match: The PPP blob which best matches to id. The best matching
;           structure is defined to be the one with maximum similarity
;           to PPV structure id. See below.
;    similarity: The similarity between PPV[id] and PPP[match]. See
;                below.
;
; KEYWORD PARAMETERS:
;  matrix: The similarity matrix. Of size[Nppp, Nppv]. Matrix[i,j]
;  gives the similarity between PPP[i] and PPV[j]. See below for how
;  similarity is defined.
;
;  mask_matrix: Another similarity matrix. Here, the similarity
;               calculation uses only the shapes of blobs, and ignores
;               their intensities (see below)
;
; BEHAVIOR:
;   Definitions:
;   PPP[i]- the ith PPP-identified structure (in PPP space) 
;   PPV[j]- the jth PPV-identified structure (in PPV space)
;   PPP'[i] - the ith PPP-identified structure, projected into PPV
;   I(x) -- the integrated intensity of some region x in PPV space
;   PPP'[ij] -- the subset of PPP'[i] that overlaps PPV[j]
;   PPV[ji] -- the subset of PPV[j] that overlaps PPP'[i]
;
;   We define the similarity between PPP[i] and PPV[j]
;   sim[i,j]^2 = I(PPP'[ij]) * I(PPV[ji]) / ( I(PPP'[i]) * I(PPV[j]))
;
;   This similarity matrix is stored into the "matrix" keyword
;
;   In addition, we repeat the comparison ignoring the intensity of
;   structures. That is, I(x) = number of pixels in x. That similarity
;   matrix is stored into mask_matrix
;
; MODIFICATION HISTORY:
;  March 2011: Written by Chris Beaumont
;-
function match_dendro, ppp, ppv, v_cube, vcen, matrix = matrix, $
                       mask_matrix = mask_matrix
  if n_params() ne 4 then begin
     print, 'calling sequence'
     print, 'result = match_dendro(ppp, ppv, v_cube, vcen, '
     print, '                      [matrix = matrix, mask_matrix = mask_matrix])'
     return, !values.f_nan
  endif
  
  if size(ppp, /type) ne 10 || ~ptr_valid(ppp) || $
     size(*ppp, /type) ne 8 then $
        message, 'ppp does not point to a structure'

  if size(ppv, /type) ne 10 || ~ptr_valid(ppv) || $
     size(*ppv, /type) ne 8 then $
        message, 'ppv does not point to a structure'

  nst = n_elements( (*ppv).height )
  nst_ppv = nst
  nan = !values.f_nan
  rec = { id:0L, match:0L, $
          similarity:nan }

  sz = size(v_cube)
  if sz[0] ne 3 then $
     message, 'ppp_cube and v_cube are not cubes with compatible sizes'
  if size(vcen, /n_dim) ne 1 then $
     message, 'vcen is not a vector'

  assert, array_equal(sz[0:3], ((*ppp).szdata)[0:3])
  mask = dblarr(sz[1], sz[2], sz[3])

  ppv_sz = (*ppv).szdata
  assert, array_equal(ppv_sz[0:2], sz[0:2])

  ppv_lab = lonarr(ppv_sz[1], ppv_sz[2], ppv_sz[3])
  ppv_val = fltarr(ppv_sz[1], ppv_sz[2], ppv_sz[3])
  ppv_lab[ (*ppv).cubeindex ] = (*ppv).cluster_label
  ppv_val[ (*ppv).cubeindex ] = (*ppv).t

  ppp_in_ppv = ppv_val * 0
  nst_ppp = n_elements( (*ppp).height) + 1
  assert, n_elements( (*ppp).cluster_label_h ) eq nst_ppp

  similarity = replicate(!values.f_nan, nst_ppp, nst_ppv)
  similarity_mask = similarity

  ;- pre-calculate leafward mergers
  leaves = ptrarr(nst_ppv)
  for i = 0, nst_ppv - 1, 1 do $
     leaves[i] = ptr_new( leafward_mergers(i, (*ppv).clusters) )
  
  ;-pre-calculate normalized intensity of each PPV struct
  ppv_norm = fltarr(nst_ppv)
  ppv_norm_flat = lonarr(nst_ppv)
  for i = 0, nst_ppv - 1 do begin
     ind = substruct(i, ppv)
     ppv_norm[i] = total( (*ppv).t[ind] )
     ppv_norm_flat[i] = n_elements(ind)
  endfor

  ;- loop over PPP structures
  for i = nst_ppp - 1, 0, -1 do begin

     ;- extract PPP struct
     if (i mod 5) eq 0 then print, i, nst_ppp - 1
     ind = substruct(i, ppp, count = ct)
     if ct lt 5 then continue
     ci = (*ppp).cubeindex[ind]

     ;- project into PPV space
     ;- crop mask to speed up projection
     mask[*] = 0
     mask[ci] = (*ppp).t[ind]
     ai = array_indices(mask, ci)
     hi = max(ai, dim = 2, min = lo)
     ra = hi - lo + 1
     stamp = reform( mask[lo[0]:hi[0], lo[1]:hi[1], lo[2]:hi[2]], $
                     ra[0], ra[1], ra[2])
     vstamp = reform(v_cube[lo[0]:hi[0], lo[1]:hi[1], lo[2]:hi[2]], $
                     ra[0], ra[1], ra[2])
     proj = cppp2ppv(stamp, vstamp, vcen)

     ;assert, abs(total(proj) - total(stamp)) / (total(stamp) > 1d-30) lt 1e-2
     
     ;- insert cropped projection into correctly sized cube
     ppp_in_ppv[*] = 0
     assert, array_size_equal(ppp_in_ppv[lo[0]:hi[0], lo[1]:hi[1], *], proj)
     ppp_in_ppv[lo[0]:hi[0], lo[1]:hi[1], *] = proj
     ppp_norm = total(proj)
     assert, ppp_norm ne 0
     ;assert, abs(ppp_norm - total(stamp)) lt total(stamp) * 1d-3

     ;- make histogram of the ID's of overlapping PPV pixels
     hit = where(ppp_in_ppv ne 0, num_ppp)
     assert, num_ppp ne 0
     v = ppv_lab[hit]
     h = histogram(v, min = 0, max = nst_ppv, rev = ri)

     ;- compute similarity for each ppv struct j
     for j = 0, nst_ppv - 1, 1 do begin

        ;- find all substructures within PPV struct j
        ;- make sure there's an overlap with i
        l = *(leaves[j])
        if total(h[l]) eq 0 then continue

        ;- get all pixels in the overlap region
        overlap = lonarr(total(h[l]))
        pos = 0
        for k = 0, n_elements(l) - 1, 1 do begin
           dpos = h[l[k]]
           if dpos eq 0 then continue
           overlap[pos] = hit[ri[ri[l[k]] : ri[l[k] + 1] - 1]]
           pos += dpos
        endfor
        
        xx = total(double(ppp_in_ppv[overlap]))
        yy = total(double(ppv_val[overlap]))
        sim1 = sqrt(xx / ppp_norm) * sqrt(yy / ppv_norm[j])
        sim2 = 1. * n_elements(overlap) / $
               (1. * sqrt(num_ppp) * sqrt(ppv_norm_flat[j]))
        if sim2 gt .8 then print, n_elements(overlap), num_ppp, $
                                  ppv_norm_flat[j]

        if sim1 le 0 || sim1 ge 1.001 || $
           sim2 le 0 || sim2 ge 1.001 then begin
           print, sim1, sim2
        endif
        
        assert, sim1 ge 0 && sim1 lt 1.001
        assert, sim2 ge 0 && sim2 lt 1.001
        
        similarity[i,j] = sim1
        similarity_mask[i,j] = sim2

     endfor
     print, 'Finished with PPP struct ', i
     print, 'Max similarity: ', max(similarity[i,*], loc1, /nan)
     print, 'Max mask sim:   ', max(similarity_mask[i,*], loc2, /nan)
     print, 'Indices of max: ', loc1, loc2
  endfor
  ptr_free, leaves

  ;- find best match for each PPV struct
  best = max(similarity, loc, dim = 1, /nan)
  in = array_indices(similarity, loc)
  assert, array_equal( reform(in[1,*]), indgen(n_elements(in[0,*])))
  loc = reform(in[0,*])

  assert, n_elements(best) eq nst_ppv

  data = replicate(rec, nst_ppv)
  data.id = indgen(nst)
  data.match = loc
  data.similarity = best

  matrix = similarity
  mask_matrix = similarity_mask
  return, data
end
