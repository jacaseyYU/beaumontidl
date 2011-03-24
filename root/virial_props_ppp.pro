function virial_props_ppp, ptr, vel, len_scale = len_scale, vel_scale = vel_scale, flux2mass = flux2mass

  if n_params() ne 2 then begin
     print, 'calling sequence:'
     print, ' result = virial_props_ppp(ptr, vel, [len_scale = len_scale, vel_scale = vel_scale, flux2mass = flux2mass)'
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
     if (*ptr).cluster_label_h[i] eq 0 then continue

     if (i + 1) mod 20 eq 0 then print, i+1, nst

     ind = substruct(i, ptr, count = ct)
     x = (*ptr).x[ind] & y = (*ptr).y[ind] & v = (*ptr).v[ind] & t = (*ptr).t[ind]
     ci = (*ptr).cubeindex[ind]

     stamp = fltarr( range(x)+2, range(y)+2, range(v) + 2)
     stamp[ x- min(x), y - min(y), v - min(v) ] = t

     indices, stamp, ix, iy, iz
     
     shape_stat3, stamp, mean = mean, $
                  paxis = paxis, obl = obl, $
                  sph = sph

     ix -= mean[0] & iy -= mean[1] & iz -= mean[2]
     
     ax1 = reform(paxis[*,0])
     ax1 /= sqrt( total(ax1^2) )
     
     ax2 = reform(paxis[*,1])
     ax2 /= sqrt( total(ax2^2) )
     
     ax3 = reform(paxis[*,2])
     ax3 /= sqrt( total(ax3^2) )
     
     
     ;- project (xy) onto the major/minor axes in XY plane
     p_1 = ix * ax1[0] + iy * ax1[1] + iz * ax1[2]
     p_2 = ix * ax2[0] + iy * ax2[1] + iz * ax2[2]
     p_3 = ix * ax3[0] + iy * ax3[1] + iz * ax3[2]
     assert, total(stamp * p_1) lt 1e-3 * total(stamp)
     assert, total(stamp * p_2) lt 1e-3 * total(stamp)
     assert, total(stamp * p_3) lt 1e-3 * total(stamp)

     tt = total(stamp)
     assert, abs(total(t) - tt) / tt lt 1d-3
     sig_maj = sqrt(total(stamp * p_1^2) / tt) * len_scale
     sig_min = sqrt(total(stamp * p_2^2) / tt) * len_scale
     assert, sig_maj ge sig_min

     uvel = total(t * vel[ci]) / tt
     sig_vel = sqrt(  total(t * (vel[ci] - uvel)^2) / tt  ) * vel_scale
     sig_r = sqrt(sig_maj * sig_min)
     
     data[i].sig_maj = sig_maj
     data[i].sig_min = sig_min
     data[i].sig_v = sig_vel
     data[i].sig_r = sig_r
     data[i].flux = tt
     data[i].vol = n_elements(t) * len_scale^3D
  endfor
  eta = 1.91
  data.virial = 5 * eta * data.sig_r * data.sig_v^2 / (data.flux * flux2mass * apcon('G'))
  return, data
end
  


