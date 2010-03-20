;+
; PURPOSE:
;  This function attempts to match a provided ra and dec to a CCD
;  number for the megacam data. I make several assumptions:
;   - (a,d) is falls on the same CCD as its nearest neighbor in the
;     catalog
;   - all measurements of this neighbor fall on the same CCD, so that
;     I can just look at the first measurement.
;
; INPUTS:
;  m: The .cpm catdir
;  t: The .cpt catdir
;  images: The Images.dat data
;  a: Requested RA, in degrees
;  b: Requested dec, in degrees
;
; OUTPUTS:
;  The CCD number of the first detection of the closest object to
;  (a,d)
;
; MODIFICATION HISTORY:
;  October 2009: Written by Chris Beaumont
;-
function pos2ccd, m, t, images, a, d

  ;- check inputs
  if n_params() ne 5 then begin
     print, 'pos2ccd calling sequence:'
     print, 'result = pos2ccd(m, t, images, a, d)'
     return, -1
  endif


  ;- find nearest neighbor
  a_ref = t.ra
  d_ref = t.dec
  dist = (a - a_ref)^2 + (d - d_ref)^2
  min = min(dist, minloc)
  if sqrt(min) gt 3600 then $
     message, 'Error: requested (a,d) more than a degree away from closest object'


  ;- get CCD number corresponding to first detection
  image_id = m[t[minloc].off_measure].image_id
  image_name = images[image_id - 1].name
  ccd = strpos(image_name,'ccd')
  ccd = strmid(image_name, ccd + 3, 3)
  return, fix(ccd)
end
  
