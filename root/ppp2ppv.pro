;+
; PURPOSE:
;  This function generates a PPV cube from a PPP cube + velocity
;  field.
;
; INPUTS:
;  ppp: The ppp cube
;  vel: The velocity field -- same size as ppp
;  bincenters: A regularly-spaced grid of bin centers used to define
;  the velocity spacing of the PPV cube. It also sets the pixel size
;  of the output cube's third dimension.
;
; KEYWORD PARAMETERS:
;  dimension: Set to an integer 1-3 to specify over which spatial
;  dimension the cube is integrated. Defaults to 3
;
; OUTPUTS:
;  A ppv cube. The velocity axis is always the third axis
;
; BEHAVIOR:
;  If the ppp cube dimensions are (nx, ny, nz) and the bincenters
;  vector has nv elements, the dimensions of the output cube are as
;  follows: 
;
;   dimension keyword value      output cube dimensions
;            1                       (ny, nz, nv)
;            2                       (nx, nz, nv)
;            3 (default)             (nx, ny, nv)
;
;   This program takes care to interpolate the PPP cube when adjacent
;   pixels along a single PPP line of sight project into non-adjacent
;   pixels in PPV. This suppresses sampling artifacts. It also
;   preserves the sum of the cube along each line of sight. In other
;   words, total(ppp, dimension) and total(ppv, 3) will give the same
;   result. 
;
; MODIFICATION HISTORY:
;  Jan 21 2011: Written by Chris Beaumont
;  March 2011: Fixed interpolation scheme so flux is conserved
;-
function ppp2ppv, ppp, vel, bincenters, dimension = dimension, mask = mask
  compile_opt idl2
  DEBUG = 0

  if n_params() ne 3 then begin
     print, 'Calling sequence:'
     print, 'result = ppp2ppv(ppp, vel, bincenters, [dimension = dimension, /mask])'
     return, !values.f_nan
  endif

  if ~keyword_set(dimension) then dimension = 3
  doMask = keyword_set(mask)

  if dimension lt 1 || dimension gt 3 then $
     message, 'dimension must be 1, 2, or 3'

  sz = size(ppp)
  if sz[0] ne 3 then $
     message, 'ppp must be a data cube'
  
  if n_elements(vel) ne n_elements(ppp) then $
     message, 'ppp and vel must be the same size'

  binsize = bincenters - shift(bincenters, 1)
  binsize[0] = binsize[1]
  if abs(range(binsize) / mean(binsize)) gt 1d-2 then $
     message, 'bincenters are not uniformly spaced'
  binsize = binsize[0]

  nbin = n_elements(bincenters)
  
  case dimension of
     1: begin
        data = transpose(ppp, [1, 2, 0])
        velo = transpose(vel, [1, 2, 0])
     end
     2: begin
        data = transpose(ppp, [0, 2, 1])
        velo = transpose(vel, [0, 2, 1])
     end
     3: begin
        data = ppp
        velo = vel
     end
  endcase

  sz = size(data)
  
  ;- IDL trims off trailing dimensions of size 1.
  ;- put it back if needed. annoying
  if sz[0] ne 3 then begin
     data = reform(data, sz[1], sz[0] eq 2 ? sz[2] : 1, 1, /over)
     velo = reform(velo, sz[1], sz[0] eq 2 ? sz[2] : 1, 1, /over)
     sz = size(data)
  endif
  assert, sz[0] eq 3

  result = doMask ? bytarr(sz[1], sz[2], nbin) : dblarr(sz[1], sz[2], nbin)
  assert, (size(result))[0] eq 3
  ind = floor((velo - (bincenters[0] - binsize/2.)) / binsize)
  valid = (ind ge 0) and (ind lt n_elements(bincenters))
  
  data = doMask ? byte(data ne 0 and valid) : data * valid
  
  x = lindgen(sz[1] * sz[2]) mod sz[1]
  y = lindgen(sz[1] * sz[2]) / sz[1]

  for i = 0, sz[3] - 1 do begin
     z = x * 0 + i
     z1 = (i eq (sz[3] - 1)) ? z : z + 1
     v = ind[x, y, z]
     v1 = ind[x,y,z1]

     jump = 3 * fix(max(abs(v1 - v)) + 1)
     for j = 0, jump-1, 1 do begin
        w = 1.0 * j / jump
        ;val = data[x, y, z] * (1 - w) + data[x,y,z1] * w
        val = data[x,y,z]
        vp = floor(v * (1 - w) + v1 * w)
        if doMask then $
           result[x,y,vp] or= val $
        else $
           result[x,y,vp] += val / float(jump)
     endfor
  endfor

  ;- make sure we preserve flux
  if ~doMask && DEBUG then $
     assert, abs(total(result) - total(data)) / total(data) lt 1d-3

  return, result
end


pro test

  data = fltarr(3, 3, 3) + 1
  indices, data, x, y, z
  xvel = 1. * x
  bincenters = findgen(3)
  ppv = ppp2ppv(data, xvel, bincenters)

  answer = [ [ [3, 0, 0], [3, 0, 0], [3, 0, 0] ], $
             [ [0, 3, 0], [0, 3, 0], [0, 3, 0] ], $
             [ [0, 0, 3], [0, 0, 3], [0, 0, 3] ] ]
  assert, min( abs(ppv - answer) lt 1e-5 )
  
  
  ppv = ppp2ppv(data, xvel, bincenters, /dim)
  assert, min( abs(ppv - replicate(1, 3, 3, 3)) lt 1e-5 )

  ppv = ppp2ppv(data, xvel, bincenters, dim = 2)
  assert, min( abs(ppv - answer) lt 1e-5 )
  print, 'all tests passed'
end
