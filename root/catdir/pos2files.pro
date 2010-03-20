;+
; PURPOSE:
;  This function attempts to match a provided ra and dec to a set of
;  file names in a CATDIR
;
; MODIFICATION HISTORY:
;  October 2009: Written by Chris Beaumont
;-
function pos2files, images, m, in_t, a, d, ave_ref = ave_ref

  ;- check inputs
  if n_params() ne 5 then begin
     print, 'pos2files calling sequence:'
     print, 'pos2files, images, m, in_t, a, d'
     return, 0
  endif

  good = where(in_t.nmeasure gt 100)
  t = in_t[good]
  
  ;- find nearest neighbor
  if keyword_set(ave_ref) then begin
     ind = where(m.ave_ref eq ave_ref, ct)
     if ct eq 0 then begin
        print, averef, 'not found in catdir'
        return, 0
     endif
     subm = m[ind]
  endif else begin

     a_ref = t.ra
     d_ref = t.dec
     dist = (a - a_ref)^2 + (d - d_ref)^2
     
     lo = min(dist, minloc)
     if sqrt(lo) gt 600 then $
        message, 'No nearby detections to (a,d)'

     lo = t[minloc].off_measure
     hi = lo + t[minloc].nmeasure - 1
     ind = arrgen(lo, hi, 1)

     subm = m[t[minloc].off_measure : t[minloc].off_measure + t[minloc].nmeasure - 1]
  endelse

  subim = subm.image_id
  
  subm = subm[sort(subim)]
  ind = ind[sort(subim)]
  subim = subim[sort(subim)]
  
  subim = images[subim - 1].name
  
  print, transpose([[subim], [string(subm.x_ccd)], [string(subm.y_ccd)], [string(ind)], [string(subm.photcode)]])
; print, t[minloc].ra, t[minloc].dec
  print, subm[0].ave_ref
  return, subim
  
  
end
  
