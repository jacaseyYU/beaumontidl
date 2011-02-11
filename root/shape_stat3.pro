;+
; PURPOSE:
;  This procedure computes several moment-based shape statistics for a
;  3D volume. They include the center of mass, moment of inerta
;  tensor, and principal moments/axes.
;
; INPUTS:
;  Image: A 3D image, treated as an array of weights. These really
;         should be non-negative, and their sum must be positive.
; 
; KEYWORD PARAMETERS:
;  mask: An optional input mask array - image will be multiplied by
;                                       mass before analysis
;  mean: On output, the mean, or center-of-mass, of the volume
;  moment: A 3x3 symmetric moment of inertia tensor
;  pmom: The 3 principal moments of inertia, listed in ascending
;        order. 
;  paxis: A 3x3 array, whose ith row gives the coordinates of the ith
;         principal moment vector. The first vector (corresponding to
;         the smallest moment) points in the direction of maximum
;         elongation. 
;  oblateness: An oblateness parameter, given by 
;              2/pi * atan[(P_3 - P_2)/(P_2 - P_1)], where P_i is the
;              i'th principal moment. This ranges from [0,1],
;              with 0 corresponding to a prolate ellipsoid, and 1
;              corresponding ot an oblate one.
;  sphericity: A sphericity parameter, given by 1- (P_3 - P_1) / P_3. 
;              1 corresponds to a perfect sphere. 
;
; MODIFICATION HISTORY:
;  June 2010: Written by Chris Beaumont
;-
pro shape_stat3, image, $
                 mask = mask, $
                 mean = mean, $
                 moment = moment, $
                 pmom = pmom, $
                 paxis = paxis, $
                 oblateness = oblateness, $
                 sphericity = sphericity

  compile_opt idl2

  ;- check inputs
  if n_params() ne 1 then begin
     print, 'Calling sqeuence'
     print, 'shape_stat3, image, mask = mask, mean = mean,'
     print, '             moment=moment, pmom = pmom, paxis = paxis'
     return
  endif

  nd = size(image, /n_dim)
  if nd ne 3 then message, 'Image must be a 3D array'

  m = double(image * (keyword_set(mask) ? mask : 1))
  if total(m lt 0) then $
     message, 'Total of image is negative -- cannot continue'
  if min(m lt 0) then $
     message, /con, 'WARNING: some elements of the input are negative. Bad times...'

  indices, m, x, y, z
  if n_elements(z) eq 0 then z = x * 0

  ;-the mean
  ux = total(x * m) / total(m)
  uy = total(y * m) / total(m)
  uz = total(z * m) / total(m)
  mean = [ux, uy, uz]

  ;-the moment of inertia tensor, about the mean
  x -= ux & y -= uy & z -= uz
  moment = replicate(m[0], 3, 3)
  moment[0,0] = total(m * (y^2 + z^2))
  moment[0,1] = -total(m * x * y) & moment[1,0] = moment[0,1]
  moment[0,2] = -total(m * x * z) & moment[2,0] = moment[0,2]
  moment[1,1] = total(m * (x^2 + z^2))
  moment[1,2] = -total(m * y * z) & moment[2,1] = moment[1,2]
  moment[2,2] = total(m * (x^2 + y^2))

  ;- the principal moments and axes
  pmom = eigenql(moment, /absolute, /double, eigenvectors = paxis, $
                /ascending)

  oblateness = 2/!pi * atan((pmom[2] - pmom[1]) / (pmom[1] - pmom[0]))
  sphericity = 1 - (pmom[2] - pmom[0]) / pmom[2]
end

pro test
  fmt = '(3(3x, e9.2))'
  div = '*******************'
  ;- a circle
  print, div
  print, 'Circle'
  m = fltarr(50, 50, 50)
  indices, m, x, y, z
  x -=25 & y -= 25 & z -= 25
  m = sqrt(x^2 + y^2 + z^2)

  shape_stat3, m, mean = mean, moment = moment, pmom = pmom, pax = pax, $
               ob = ob, sph = sph
  print, 'Mean'
  print, mean, format= fmt
  print, 'Moment'
  print, moment, format=fmt
  print, 'Principal Moments'
  print, pmom, format=fmt
  print, 'Principal Axes'
  print, pax, format = fmt
  print, 'Oblateness'
  print, ob
  print, 'Sphericity'
  print, sph

  print, div
  print, 'Prolate ellipse along X axis'
  a = 20. & b = 4. & c = 4.
  m = x^2/a^2 + y^2/b^2 + z^2/c^2 lt 1.
  shape_stat3, m, mean = mean, moment = moment, pmom = pmom, pax = pax, $
               ob = ob, sph = sph
  print, 'Mean'
  print, mean, format= fmt
  print, 'Moment'
  print, moment, format=fmt
  print, 'Principal Moments'
  print, pmom, format=fmt
  print, 'Principal Axes'
  print, pax, format = fmt
  print, 'Oblateness'
  print, ob
  print, 'Sphericity'
  print, sph
  tvimage, bytscl(total(m,3)), /noint  

  print, div
  print, 'Oblate ellipse along y axis'
  a = 10. & b = 4. & c = 10.
  m = x^2/a^2 + y^2/b^2 + z^2/c^2 lt 1.
  shape_stat3, m, mean = mean, moment = moment, pmom = pmom, pax = pax, $
               ob = ob, sph = sph
  print, 'Mean'
  print, mean, format= fmt
  print, 'Moment'
  print, moment, format=fmt
  print, 'Principal Moments'
  print, pmom, format=fmt
  print, 'Principal Axes'
  print, pax, format = fmt
  print, 'Oblateness'
  print, ob
  print, 'Sphericity'
  print, sph
  erase
  tvimage, bytscl(total(m,2)), /noint  

end
  
