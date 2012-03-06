;+
; PURPOSE:
;  Calculates the similarity of a PPP structure, defined by a contour
;  level and a point in the region of interest, and a PPV structure
;
; INPUTS:
;  inten: The value of the contour to use
;
; KEYWORD PARAMETERS:
;  seed: The 1D index, in PPP cube, of a point in the region of
;        interest
;  ppv_index: The index of the PPV dendrogram structure to compare to
;  ppv_dendro: Pointer to the PPV dendrogram
;  ppp_cube: The ppp cube
;  v_cube: The line-of-sight velocity cube
;  vcen: The velocity at the center of each bin in the ppv cube
;  smear: The amount to smear the ppp structure, after projection
;
; RETURNS:
;  -1 * similarity statistic
;
; MODIFICATION HISTORY:
;  October 2011: Written by Chris Beaumont
;  Jan 2012: Debugged, tested by Chris Beaumont
;-
function dendro_match_single, inten, seed = seed, ppv_index = ppv_index, ppv_dendro = ppv_dendro, $
                              ppp_cube = ppp_cube, v_cube = v_cube, vcen = vcen, smear = smear

  debug = 0
  ;- isolate region of ppp cube
  mask = ppp_cube ge inten
  if mask[seed] eq 0 then begin
     return, 0
  endif

  r = label_region_edges(mask, /ulong)
  assert, r[seed] ne 0
  mask *= (r eq r[seed])

  ;- extract to postage stamp for speed
  hit = where(mask eq 1, ct)
  assert, ct gt 0

  xyz = array_indices(mask, hit)
  if ct eq 1 then begin
     lo = xyz
     hi = xyz
  endif else begin
     lo = min(xyz, dim = 2, max = hi)
  endelse
  hi[2] = (hi[2] + 1) < (n_elements(mask[0,0,*]) - 1)
  lo[2] = (lo[2] - 1) > 0
  ra = hi - lo + 1

  stamp = (ppp_cube * mask)[lo[0] : hi[0], lo[1] : hi[1], lo[2] : hi[2]]
  vstamp = v_cube[lo[0] : hi[0], lo[1] : hi[1], lo[2] : hi[2]]
  proj = cppp2ppv(stamp, vstamp, vcen, smear = smear)
  ;proj = cppp2ppv(ppp_cube * mask, v_cube, vcen, smear = smear)

  ppv_stamp = fltarr(ra[0] + 2, ra[1] + 2, n_elements(vcen))
  ind = substruct(ppv_index, ppv_dendro)
  ci = (*ppv_dendro).cubeindex[ind]
  xyz = array_indices((*ppv_dendro).szdata[1:3], ci, /dim)
  x = xyz[0,*] - lo[0] + 1
  y = xyz[1,*] - lo[1] + 1
  v = xyz[2,*]
  x>=0
  x <= (ra[0] + 1)
  y >= 0
  y <= (ra[1] + 1)

  ppv_stamp[x, y, v] = (*ppv_dendro).t[ind]
  ppv_stamp = ppv_stamp[1:ra[0], 1:ra[1], *]
  ;ppv_stamp = fltarr( (*ppv_dendro).szdata[1], $
  ;                    (*ppv_dendro).szdata[2], $
  ;                    (*ppv_dendro).szdata[3])
  ;ind = substruct(ppv_index, ppv_dendro)
  ;ci = (*ppv_dendro).cubeindex[ind]
  ;ppv_stamp[ci] = (*ppv_dendro).t[ind]

  ppp_tot = total(double(proj))
  ppv_tot = total(double((*ppv_dendro).t[ind]))
  overlap = total(proj * ppv_stamp)

  hit = where(proj ne 0 and ppv_stamp ne 0, ct)
  if ct eq 0 then return, 0
  result = sqrt( total(double(proj[hit])) / ppp_tot) * sqrt(total(double(ppv_stamp[hit])) / ppv_tot)
  if debug then begin
     print, total(double(proj[hit])), ppp_tot
     print, total(double(ppv_stamp[hit])), ppv_tot
     print, n_elements(hit)
     save, proj, file='match2.sav'
  endif

  return, result * (-1)
end
