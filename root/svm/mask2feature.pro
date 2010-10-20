;+
; The default feature vector
; a 28x28x100 stamp, binned to 4x4x10
;-
function default_feature, data, x, y, z, norm = norm
  sz = size(data)
  if x lt 15 || x gt sz[1] - 15 || $
     y lt 15 || y gt sz[2] - 15 || $
     z lt 50 || z gt sz[3] - 50 then return, replicate(0, 160)
  stamp = rebin(data[x-14 : x + 13, y - 14 : y + 13, z - 50 : z + 49], 4, 4, 10)
  result = reform(stamp, 160, /over); / sqrt(total(stamp^2)) * 10 ;- more sig figs
  if keywrd_set(norm) then result /= sqrt(total(result)^2)
  return, result
end


;+ 
; stamps of the gradients
; 30x30x98, binned to 3x3x7, for each of dx, dy, dz
;-
function edge_feature, data, x, y, z, norm = norm
  common edge_feature, dx, dy, dz
  if n_elements(dx) eq 0 then begin
     dx= mrdfits('mosaic_gradx.fits',0,h)
     dy= mrdfits('mosaic_grady.fits',0,h)
     dz= mrdfits('mosaic_gradz.fits',0,h)
  endif
  sz = size(data)
  if x lt 15 || x gt sz[1] - 15 || $
     y lt 15 || y gt sz[2] - 15 || $
     z lt 50 || z gt sz[3] - 50 then return, replicate(0, 189)
  
  r1 = reform(rebin(dx[x-15:x+14, y-15:y+14, z-49:z+48], 3, 3, 7), 63)
  r2 = reform(rebin(dy[x-15:x+14, y-15:y+14, z-49:z+48], 3, 3, 7), 63)
  r3 = reform(rebin(dz[x-15:x+14, y-15:y+14, z-49:z+48], 3, 3, 7), 63)
  result = [r1, r2, r3]
  if keyword_set(norm) then result /= sqrt(total(result^2))
;  result /= sqrt(total(result^2))
;  result *= 10 ;- get more sig figs, when truncated at 2 decimals
  return, result
end


;+ 
; profiles of the gradients
; 30x30x98, binned to 6x6x7, for each of dx, dy, dz.
; THEN - take the mean xprofile, yprofile, zprofile (57 features)
;-
function edge2_feature, data, x, y, z, norm = norm
  common edge_feature, dx, dy, dz
  if n_elements(dx) eq 0 then begin
     dx= mrdfits('mosaic_gradx.fits',0,h)
     dy= mrdfits('mosaic_grady.fits',0,h)
     dz= mrdfits('mosaic_gradz.fits',0,h)
  endif

  sz = size(data)
  if x lt 15 || x gt sz[1] - 15 || $
     y lt 15 || y gt sz[2] - 15 || $
     z lt 50 || z gt sz[3] - 50 then return, replicate(0, 57)
  
  r1 = rebin(dx[x-15:x+14, y-15:y+14, z-49:z+48], 6, 6, 7)
  r2 = rebin(dy[x-15:x+14, y-15:y+14, z-49:z+48], 6, 6, 7)
  r3 = rebin(dz[x-15:x+14, y-15:y+14, z-49:z+48], 6, 6, 7)

  r1x = total(total(r1, 2), 2)
  r1y = total(total(r1, 1), 2)
  r1z = total(total(r1, 1), 1)

  r2x = total(total(r2, 2), 2)
  r2y = total(total(r2, 1), 2)
  r2z = total(total(r2, 1), 1)

  r3x = total(total(r3, 2), 2)
  r3y = total(total(r3, 1), 2)
  r3z = total(total(r3, 1), 1)

  result = [r1x, r1y, r1z, r2x, r2y, r2z, r3x, r3y, r3z]
  if keyword_set(norm) then result /= sqrt(total(result^2))
;  result /= sqrt(total(result^2))
;  result *= 10 ;- get more sig figs, when truncated to 2 decimals
  return, result
end


;+
; the moments. mean, 2 moment for x,y,z
;-
function moment_feature, data, x, y, z, norm = norm
  common moment_feature, ix, iy, iz
  if n_elements(ix) eq 0 then begin
     ix = findgen(28)  / 27. & iy = ix
     iz = findgen(100) / 99.
  endif
  sz = size(data)
  if x lt 15 || x gt sz[1] - 15 || $
     y lt 15 || y gt sz[2] - 15 || $
     z lt 50 || z gt sz[3] - 50 then return, replicate(0, 7)
  
  stamp= data[x-14:x+13, y-14:y+13, z-50:z+49]
  xp = total(total(stamp, 2), 2) > 0
  yp = total(total(stamp, 1), 2) > 0
  zp = total(total(stamp, 1), 1) > 0

  ux = total(xp * ix) / total(xp)
  uy = total(yp * iy) / total(yp)
  uz = total(zp * iz) / total(zp)
  sx = total((ix - ux)^2 * xp) / total(xp)
  sy = total((iy - uy)^2 * yp) / total(yp)
  sz = total((iz - uz)^2 * zp) / total(zp)
  result = [mean(stamp), ux, sx, uy, sy, uz, sz]
  if keyword_set(norm) then result /= sqrt(total(result^2))
  return, result
end


function pca_feature, data, x, y, z, norm = norm
  common pca_feature, pca
  sz = size(data)
  if n_elements(pca) eq 0 then begin
     restore, 'feature_pca.sav'
     resolve_routine, 'pricom__define'
  endif

  if x lt 15 || x gt sz[1] - 15 || $
     y lt 15 || y gt sz[2] - 15 || $
     z lt 50 || z gt sz[3] - 50 then return, replicate(0, 15)
  subim = reform(rebin(data[x-15:x+14, y-15:y+14, z-50:z+49], 15, 15, 50), $
                 11250, /over)
  proj = pca->project(subim, coeff = result, nterm = 15)
  if keyword_set(norm) then result /= sqrt(total(result^2))
;  message, 'you must normalize!'
  return, result
end

pro generate_pca

  m = mrdfits('mosaic.fits', 0, h)
  nanswap, m, 0
  sz = size(m)
  nx = sz[1] / 30 -1 & ny = sz[2] / 30 -1 & nz = sz[3] / 100 - 1
  x = rebin(indgen(nx) * 30, nx, ny, nz)
  y = rebin(1#indgen(ny) * 30, nx, ny, nz)
  z = rebin(reform(indgen(nz) * 100, 1, 1, nz), nx, ny, nz)
  
  num = long(nx) * long(ny) * long(nz)
  print, num * 2
  data = fltarr(11250, 2 * num)
  dx = 15 & dy = 15 & dz = 50
  for i = 0L, num - 1, 1 do begin
     print, i, num
     data[*, 2*i] = rebin(m[x[i]:x[i]+29, y[i]:y[i]+29, z[i]:z[i]+99], 15, 15, 50)
     data[*, 2*i+1] = rebin(m[x[i]+dx :x[i]+29+dx, y[i]+dy : y[i]+29+dy, z[i]+dz :z[i]+99+dz], 15, 15, 50)
  endfor
;  stop
  pca = obj_new('pricom', data)
  save, pca, file='feature_pca.sav'
end

;+
; convert a idl save file to a list of feature vectors
;-
function mask2feature, maskfile, label = label, bin = bin, $
                       featurefunction = featurefunction, norm = norm, $
                       data = data, mask = mask, help=help
  common svmdata, d, h  

  if keyword_set(help) || n_params() eq 0 && n_elements(mask) eq 0 then begin
     print, 'calling sequence:'
     print, ' result = mask2feature(maskfile, [label = label, bin = bin,'
     print, '            featurefunction=string, /norm, data=data, mask=mask)'
     return, -1
  endif

  if n_elements(data) eq 0 then begin
     if n_elements(d) eq 0 then read_data
     data = d
  endif

  if n_elements(mask) eq 0 then restore, maskfile

  ;- trim off the edges
  sz = size(mask)
  mask[0:10, *, *] = 0
  mask[sz[1]-10:*, *, *] = 0
  mask[*, 0:10, *] = 0
  mask[*, sz[2]-10:*, *] = 0
  mask[*,*,0:50] =0 
  mask[*,*,sz[3]-50:*] = 0
  
  hit = where(mask, ct)
  ind = array_indices(mask, hit)

  ;- snap values to a grid, and eliminate duplicates
  if keyword_set(bin) then begin
     x = ind[0,*] & y = ind[1,*] & z = ind[2, *]
     x = floor(x / bin[0]) * bin[0]
     y = floor(y / bin[1]) * bin[1]
     z = floor(z / bin[2]) * bin[2]
     mask *= 0B
     mask[x,y,z] = 1
     hit = where(mask)
     ind = array_indices(mask, hit)
     ct = n_elements(hit)
  endif
;  stop

  ;- get dimensionality of feature function
  if keyword_set(featurefunction) then begin
     junk = call_function(featurefunction, data, sz[1]/2, $
                          sz[2]/2, sz[3]/2, norm = norm)
     ndim = n_elements(junk)
  endif else ndim = 160


  record = {feature : fltarr(ndim), x : 0, y : 0, z : 0, label : 0}
  result = replicate(record, ct)
  pbar, 'mask2feature', /new
  for i = 0L, ct - 1, 1 do begin
     if i mod 100 eq 0 then pbar, 1. * i / ct
     x = ind[0, i]
     y = ind[1, i]
     z = ind[2, i]
     result[i].x = x & result[i].y = y & result[i].z = z
     result[i].label = keyword_set(label) ? label : 0

     if keyword_set(featurefunction) then begin
        result[i].feature = call_function(featurefunction, $
                                           data, x, y, z, norm = norm)
     endif else begin
        ;- default: a 20x20x100 postage stamp, binned to 4x4x10
        subim = data[x - 10 : x + 9, y - 10 : y + 9, z - 50 : z + 49]
        result[i].feature = reform(rebin(subim, 4, 4, 10), 160, /over)
        junk = call_function('default_feature', data, x, y, z, norm = norm)
        diff = max(abs(result[i].feature - junk))
        assert, diff lt 1d-7
     endelse

  endfor
  pbar, /close

  ;- normalize
  norm = sqrt(total(result.feature^2, 1))
  assert, n_elements(norm) eq n_elements(result)
  bad = where(norm le 1d-10, ct, complement = good)
  if ct ne 0 then result = result[good]

  return, result
end

