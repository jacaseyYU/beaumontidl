;+
; PURPOSE:
;  This procedure is a wrapper to skymap_smooth, which creates a
;  smoothed map of some function sampled at discrete points on the
;  sky. Additionally, this function implements sigma clipping during
;  the smoothing. 
;
; INPUTS:
;  map: A map structure, created by map_init.pro
;  x: x location (sky coordinate in degrees) of the data
;  y: y location (sky coordinates in degrees) of the data
;  val: Value of the quantity sampled at (x,y)
;  dval: 1-sigma error on val
;
; KEYWORD PARAMETERS
;  fwhm: The fwhm of the smoothing kernel, in degrees. Defaults to
;        1/100th of the map size
;  truncate: The radius at which to truncate the smoothing kernel, in
;           degrees. Defaults to 2 fwhm.
;  emap: Set to a variable to hold the smoothed variance map
;  clip: Set to a sigma clipping threshhold (see below). Defaults to
;        5.
;  included: Set to a variable to hold a 1/0 array, indicating which
;            (x,y) pairs were used in the sigma-clipped map.
;  status: Set to a variable to return the status code of the
;          procedure. A value of 0 indicates success. Status = 1
;          indicates that too many objects were excluded during sigma
;          clipping. Status = 2 indicates that the sigma clipping
;          procedure did not converge after several iterations.
;
; OUTPUT:
;  On output, the map structure is populated with the sigma-clipped
;  map.
;
; PROCEDURE:
;  This program repeatedly calls skymap_smooth. After each call, data
;  points which deviate from the smooth map value at (x,y) by more
;  than CLIP sigma are labeled as outliers. The procedure repeats,
;  ignoring outliers, until convergence.
;
; MODIFICATION HISTORY:
;  March 2010: Written by Chris Beaumont
;-
pro skymap_smooth_sigclip, map, x, y, val, dval, $
                           fwhm = fwhm, $
                           truncate = truncate, $
                           emap = emap, clip = clip, $
                           included = included, status = status
  compile_opt idl2

  ;- check inputs
  if n_params() ne 5 then begin
     print, 'calling sequence'
     print, '  skymap_smooth_sigclip, map, x, y, val, dval, '
     print, '                 [fwhm = fwhm, truncate = truncate, '
     print, '                  emap = emap, clip = clip '
     print, '                  included = included, status = status]'
     return
  endif

  if size(map, /type) ne 8 then $
     message, 'map must be a structure. Use map_init.pro'
  tags = tag_names(map)
  if n_elements(tags) ne 2 || tags[0] ne 'MAP' || tags[1] || 'HEAD' $
     then message, 'map must be a structure. Use map_init.pro'

  nobj = n_elements(x)
  if n_elements(y) ne nobj || n_elements(val) ne nobj || $
     n_elements(dval) ne nobj then $
        message, 'x, y, val, and dval not the same size'
  
  if ~keyword_set(fwhm) then $
     fwhm = sxpar(map.head, 'naxis2') * abs(sxpar('cdelt2')) / 100.
  if ~keyword_set(truncate) then truncate = fwhm * 2
  if ~keyword_set(clip) then clip = 5
 
  include = replicate(1, nobj)
  ;- pixel coordinates of x and y
  adxy, map.head, x, y, px, py

  MAXITER = 40
  for i = 0, MAXITER - 1, 1 do begin
     
     use = where(included, ct)
     if ct lt .1 * nobj then begin
        status = 1
        return
     endif

     skymap_smooth, map, x[use], y[use], val[use], dval[use], $
                    fwhm = fwhm, truncate = truncate, $
                    emap = emap
     delta = abs(map.map[px, py] - val)
     thresh = clip * sqrt(emap[px, py] + dval^2)
     new_included = (delta lt thresh)

     ;- test for convergence
     if min(included eq new_included) eq 1 then break
     included = new_included
  endfor
  if i ge MAXITER then status = 2
end
