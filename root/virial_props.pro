function virial_props, ptr, len_scale = len_scale, vel_scale = vel_scale, flux2mass = flux2mass

  if n_params() ne 1 then begin
     print, 'calling sequence:'
     print, ' result = virial_props(ptr, [len_scale = len_scale, vel_scale = vel_scale, flux2mass = flux2mass)'
     return, !values.f_nan
  endif

  if ~keyword_set(len_scale) then len_scale = 1
  if ~keyword_set(vel_scale) then vel_scale = 1
  if ~keyword_set(flux2mass) then flux2mass = 1

  nst = n_elements( (*ptr).height )


  nan = !values.f_nan
  rec = {sig_maj:nan, sig_min:nan, sig_v:nan, $
         sig_r:nan, flux:nan, vol:nan, virial:nan}
  data = replicate(rec, nst)

  for i = 0, nst - 1, 1 do begin
     ind = substruct(i, ptr, count = ct)
     if ct eq 0 then continue

     if (i + 1) mod 20 eq 0 then print, i+1, nst

     x = (*ptr).x[ind] & y = (*ptr).y[ind] & v = (*ptr).v[ind] & t = (*ptr).t[ind]

     stamp = fltarr( range(x)+2, range(y)+2, range(v) + 2)
     stamp[ x- min(x), y - min(y), v - min(v) ] = t
     indices, stamp, ix, iy, iz

     sz = size(stamp)
     shape_stat3, reform(total(stamp, 3), sz[1], sz[2], 1), mean = mean, $
                  paxis = paxis, obl = obl, $
                  sph = sph

     mean2 = [total(ix * stamp) / total(stamp), total(iy * stamp) / total(stamp), $
              total(iz * stamp) / total(stamp)]
     assert, max(abs(mean2[0:1] - mean[0:1]) / (abs(mean[0:1]) > .005) ) lt (1d-3)
     mean = mean2
     ix -= mean[0] & iy -= mean[1] & iz -= mean[2]
     ax1 = reform(paxis[*,0] * [1,1,0])
     if max(abs(ax1)) eq 0 then ax1 = [1,0]
     ax1 /= sqrt( total(ax1^2) )
     
     ;- project (xy) onto the major/minor axes in XY plane
     p_maj = ix * ax1[0] + iy * ax1[1]
     p_min = sqrt( (ix^2 + iy^2) - p_maj^2 )

     tt = total(stamp,/double)
     assert, abs(tt - total(t,/double)) / tt lt 1d-3
     sig_maj = sqrt(total(stamp * p_maj^2) / tt) * len_scale
     sig_min = sqrt(total(stamp * p_min^2) / tt) * len_scale
     sig_vel = sqrt(total(stamp * iz^2) / tt) * vel_scale
     sig_r = sqrt(sig_maj * sig_min)

     if sig_maj lt sig_min then begin
        erase
        p = [0,0,1,1]
        tvimage, bytscl(total(stamp, 3, /nan)), /keep, /noi, pos = p
        contour, total(stamp, 3), ix, iy, /nodata, /noerase, pos = p
        oplot, [0, ax1[0]], [0, ax1[1]], color = fsc_color('red')
        stop
     endif

     data[i].sig_maj = sig_maj
     data[i].sig_min = sig_min
     data[i].sig_v = sig_vel
     data[i].sig_r = sig_r
     data[i].flux = tt
     data[i].vol = n_elements(t)
  endfor
  eta = 1.91 ;- correct for concentration of R. see rosolowsky 2008
  data.virial = 5 * eta * data.sig_r * data.sig_v^2 / (data.flux * flux2mass * apcon('G'))
  return, data
end
  
