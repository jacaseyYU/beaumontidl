;+
; PURPOSE:
;  This procedure copies a rectangular subregion of a rectangular
;  array to another one, handling all the crappy edge cases.
;
; INPUTS:
;  src: The source array (to be copied from)
;  x1: The lo x coordinate of the subregion to copy
;  y1: The lo y coordinate of the subregion to copy
;  dest: The destination array (to be copied to)
;  x2: The x coordinate in dest where x1 in src should be copied
;  y2: The y coordinate in dest where y1 in src should be copied
;  dx: The x size of the subregion to copy
;  dy: The y size of the subregion to copy
;
; KEYWORD_PARAMETERS:
;  add: Set to add the src region to dest
;  sub: Set to subtract the src region from dest
;  mult: Set to multiply the src region to dest
;  div: Set to divide the src region from dest
;
; BEHAVIOR:
;  Assuming both images are big enough, the program extracts a
;  dx-by-dy postage stamp from src at position (x1,y1), and inserts it
;  into position (x2,y2) of dest. If any part of the postae stamp
;  falls outside of either image, those pixels are quietly ignored.
;
; MODIFICATION HISTORY:
;  December 2010: Written by Chris Beaumont
;-
pro stamp, src, x1, y1, dest, x2, y2, dx, dy, $
           add = add, mult = mult, div = div, sub = sub

  if n_params() ne 8 then begin
     print, 'callng sequence'
     print, 'stamp, src, x1, y1, dest, x2, y2, dx, dy'
     return
  endif

  sz1 = size(src)
  sz2 = size(dest)

  if sz1[0] ne 2 || sz2[0] ne 2 then $
     message, 'src and dest must be 2D arrays'

  if ~is_scalar(x1) || ~is_scalar(y1) || $
     ~is_scalar(x2) || ~is_scalar(y2) || $
     ~is_scalar(dx) || ~is_scalar(dy) then $
        message, 'x1, x2, y1, y2, dx, and dy must be scalars'

  ix = rebin(indgen(dx), dx, dy, /sample)
  iy = rebin(1#indgen(dy), dx, dy, /sample)

  ix1 = ix + x1
  iy1 = iy + y1
  ix2 = ix + x2
  iy2 = iy + y2

  inside = where(ix1 ge 0 and ix2 ge 0 and $
                 ix1 le sz1[1]-1 and ix2 le sz2[1]-1 and $
                 iy1 ge 0 and iy2 ge 0 and $
                 iy1 le sz1[2]-1 and iy2 le sz2[2]-1, ct)
  if ct eq 0 then return

  if keyword_set(add) then begin
     dest[ix2[inside], iy2[inside]] += src[ix1[inside], iy1[inside]]
  endif else if keyword_set(sub) then begin
     dest[ix2[inside], iy2[inside]] -= src[ix1[inside], iy1[inside]]
  endif else if keyword_set(mult) then begin
     dest[ix2[inside], iy2[inside]] *= src[ix1[inside], iy1[inside]]
  endif else if keyword_set(div) then begin
     dest[ix2[inside], iy2[inside]] /= src[ix1[inside], iy1[inside]]
  endif else begin
     dest[ix2[inside], iy2[inside]] = src[ix1[inside], iy1[inside]]
  endelse
end

pro test

  dest = bytarr(5, 5)
  src = bytarr(2, 2) + 1


  ;- normal case, no edge issues
  stamp, src, 0, 0, dest, 2, 2, 2, 2
  assert, array_equal( dest, [[0,0,0,0,0], [0,0,0,0,0],$
                        [0,0,1,1,0], [0,0,1,1,0],$
                        [0,0,0,0,0]])

  ;- edge of dest
  dest *= 0
  stamp, src, 0, 0, dest, 4, 4, 2, 2
  assert, array_equal( dest, [[0,0,0,0,0],[0,0,0,0,0], $
                              [0,0,0,0,0],[0,0,0,0,0], $
                              [0,0,0,0,1]])

  ;- edge of src
  dest *= 0
  stamp, src, 1, 1, dest, 0, 0, 5, 5
  assert, array_equal( dest, [[1,0,0,0,0],[0,0,0,0,0], $
                              [0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]])

end

  
  
