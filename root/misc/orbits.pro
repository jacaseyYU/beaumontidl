function r, a, e, theta
return, a * (1 - e^2) / (1 + e * cos(theta))
end

function timeOfDay, a, e, angle
  ;- polar coordinates
  theta = findgen(200) / 199 * 2 * !pi
  r = r(a,e,theta)
 
  ru = r * cos(theta)
  rv = r * sin(theta)
 
  ;-Rotate the orbit CCW by angle
  rx = ru * cos(angle) - rv * sin(angle) 
  ry = ru * sin(angle) + rv * cos(angle)

  ;-find where the orbit crosses r = 1
  out = r gt 1
  cross = where(out - shift(out, 1) ne 0, ct)
  print, cross
  if ct eq 0 then return, !values.f_nan
  if ct ne 2 then stop ;- should have 0 or 2 crossings
  
  ;- find angle betwee earth-sun vector and asteroid path at these points
  result = fltarr(ct)
  sz = n_elements(rx)
  for i = 0, ct-1, 1 do begin
     if cross[i] eq 0 then begin
        ind = [sz - 1, 0, 1]
     endif else if cross[i] eq sz-1 then begin
        ind = [cross[i]-1, cross[i], 0]
     endif else begin
        ind = [-1, 0, 1] + cross[i]
     endelse
     xs = rx[ind]
     ys = ry[ind]
     asteroidVec = [xs[2] - xs[0], ys[2] - ys[0]]
     earthSunVec = [xs[1], ys[1]]
     dotProduct = total(asteroidVec * earthSunVec)
     denom = sqrt(total(asteroidVec^2) * total(earthSunVec^2))
     result[i] = acos(dotProduct / denom)
     ;-correct for range issues in arccos
     
  endfor
  return, ((result * !radeg) + 12) mod 24
end
  
  

pro orbits

theta = findgen(200)/199 * 2 * !pi

window, xsize = 500, ysize = 500
re = theta * 0 + 1

plot, [0],[0], /nodata, xra  =[-1.5, 1.5], yra = [-1.5, 1.5], /xsty, /ysty
oplot, re * cos(theta), re * sin(theta), color = fsc_color('green')
oplot, [0],[0], color = fsc_color('yellow'), psym = 6, symsize = 4

r = r(1.0, 2./3., theta)
rx = r * cos(theta)
ry = r * sin(theta)
oplot, rx * cos(.2) - ry * sin(.2), rx * sin(.2) + ry * cos(.2)

r = r(3.0, 2./3., theta)
oplot, r * cos(theta), r * sin(theta)

r = r(2, 2./3., theta)
oplot, r * cos(theta), r * sin(theta)

end
