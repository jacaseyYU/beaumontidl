;+
; PURPOSE:
;  Refine the matches made in match_dendro, by considering structures
;  defined 'between' the nodes of the dendrogram
;
; INPTUS:
;  ppv: Pointer to ppv dendrogram
;  ppp: Pointer to ppp dendrogram
;  v_cube: Radial velocity cube
;  vcen: Center velocity for each pixel along ppv
;  match: The similarity matrix generated by match_dendro
;  smear: Amount to smear structures by within cppp2ppv
;
; OUTPUTS:
;  An array of structures, with the following tags:
;   id: Id of PPV structure
;   seed: 1D index of a point in the best-matching PPP structure
;   inten: The PPP contour defining the best-matching PPP structure
;   similarity: The value of the similarity
;-
function refine_match, ppv, ppp, v_cube, vcen, match, $
                       smear = smear
  old = !except
  !except = 0
  nst = n_elements((*ppv).height)
  nst_ppv = nst
  nst_ppp = n_elements((*ppp).height)
  nleaf_ppp = (nst_ppp + 1) / 2
  loval = min((*ppp).t, /nan)

  sz = (*ppp).szdata
  ppp_cube = fltarr(sz[1], sz[2], sz[3])
  ppp_cube[(*ppp).cubeindex] = (*ppp).t

  nan = !values.f_nan
  rec = {id:0L, seed:0L, inten:0L, similarity:nan, success:0}
  result = replicate(rec, nst_ppv)

  for i = 0, nst_ppv - 1, 1 do begin

     ;- the best PPP match
     best = max(match[*, i], ind, /nan)

     ;- bracket this on either side
     isleaf = ind lt nleaf_ppp
     p = merger_partner(ind, (*ppp).clusters, merge = m)

     if isleaf then begin
        l1 = min( (*ppp).t[substruct(m, ppp)])
        l2 = min( (*ppp).t[substruct(ind, ppp)])
        l3 = (*ppp).height[ind]
        bracket = [l1, l2, l3]
     endif else begin
        l1 = m eq -1 ? loval : min((*ppp).t[substruct(m, ppp)])
        l2 = min((*ppp).t[substruct(ind, ppp)])
        parents = leafward_mergers(ind, (*ppp).clusters, /parents)
        l3 = max((*ppp).height[parents] )
        bracket = [l1, l2, l3]
     endelse

     ;- a leaf inside this ppp structure
     seed = min(leafward_mergers(ind, (*ppp).clusters))
     seed = (*ppp).seeds[seed]

     fa = dendro_match_single(bracket[0], seed = seed, ppv_index=i, ppv_dendro = ppv, $
                              ppp_cube = ppp_cube, v_cube = v_cube, vcen = vcen, smear = smear)
     fb = dendro_match_single(bracket[1], seed = seed, ppv_index=i, ppv_dendro = ppv, $
                              ppp_cube = ppp_cube, v_cube = v_cube, vcen = vcen, smear = smear)
     fc = dendro_match_single(bracket[2], seed = seed, ppv_index=i, ppv_dendro = ppv, $
                              ppp_cube = ppp_cube, v_cube = v_cube, vcen = vcen, smear = smear)

     if fb lt fa and fb lt fc then begin
        catch, theError
        if theError ne 0 then begin
           print, 'ERROR in golden min'
           catch, /cancel
           success = -1
           fmin = min([fa, fb, fc], minind)
           refine = bracket[minind]
           goto, min_end
        endif

        refine = goldenmin('dendro_match_single', bracket[0], bracket[1], $
                           bracket[2], $
                           fmin = fmin, $
                           seed = seed, ppv_index = i, ppv_dendro = ppv, $
                           ppp_cube = ppp_cube, v_cube = v_cube, vcen = vcen, $
                           smear = smear, $
                           /verbose)
        success = 1
        catch, /cancel
     endif else begin
        print, 'fail'
        success = 0
        fmin = min([fa, fb, fc], minind)
        refine = bracket[minind]
     endelse

     min_end:
     print, string(i, best, fmin * (-1), format='("Improved id ", i0.0, " from ", e0.2, " to ", e0.2)')
     result[i].id = i
     result[i].seed = seed
     result[i].inten = refine
     result[i].similarity = fmin * (-1)
     result[i].success = success
  endfor
  !except = old
  return, result
end
