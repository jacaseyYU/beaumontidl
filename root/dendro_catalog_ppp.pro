function dendro_catalog_ppp, file, vel, $
                             len_scale = len_scale, $
                             vel_scale = vel_scale, $
                             flux2mass = flux2mass

  if n_params() ne 2 then begin
     print, 'calling sequence:'
     print, ' result = dendro_catalog_ppp(file, vel, [len_scale = len_scale, '
     print, '                             vel_scale = vel_scale, flux2mass = flux2mass])'
     return, !values.f_nan
  endif

  if ~file_test(file) then $
     message, 'Cannot find dendrogram file: ', file

  catch, error
  if error ne 0 then begin
     catch, /cancel
     print, 'Could not convert file to pointer: '+file
     print, !error_state.msg
     return, !values.f_nan
  endif
  ptr = dendrocpp2idl(file)
  catch, /cancel

  if ~keyword_set(len_scale) then len_scale = 1
  if ~keyword_set(vel_scale) then vel_scale = 1
  if ~keyword_set(flux2mass) then flux2mass = 1

  nst = n_elements( (*ptr).height )

  nan = !values.f_nan
  rec = {sig_maj:nan, $
         sig_min:nan, $
         sig_v:nan, $
         sig_r:nan, $
         flux:nan, $
         vol:nan, $
         virial:nan, $
         shoulder_height:nan, $
         vol_left:nan, $
         vol_right:nan}

  data = replicate(rec, nst)

  for i = 0, nst - 1, 1 do begin
     ind = substruct(i, ptr, count = ct)
     if ct eq 0 then continue
     ci = (*ptr).cubeindex[ind]

     x = (*ptr).x[ind]
     y = (*ptr).y[ind] 
     v = (*ptr).v[ind] 
     t = (*ptr).t[ind]

     stamp = dblarr( range(x)+2, range(y)+2, range(v) + 2)
     stamp[ x- min(x), y - min(y), v - min(v) ] = t
     indices, stamp, ix, iy, iz

     ;- get shape statistics for 2D projection
     sz = size(stamp)
     shape_stat3, stamp, mean = mean, $
                  paxis = paxis, obl = obl, $
                  sph = sph

     tt = total(stamp,/double)

     ;- find normalized principle axis for 2D projection
     ix -= mean[0] & iy -= mean[1] & iz -= mean[2]
     
     ax1 = reform(paxis[*,0])
     ax1 /= sqrt( total(ax1^2) )

     ax2 = reform(paxis[*,1])
     ax2 /= sqrt( total(ax2^2) )

     ax3 = reform(paxis[*,2])
     ax3 /= sqrt( total(ax3^2) )
     
     ;- project onto the major/minor axes
     p_1 = ix * ax1[0] + iy * ax1[1] + iz * ax1[2]
     p_2 = ix * ax2[0] + iy * ax2[1] + iz * ax2[2]
     p_3 = ix * ax3[0] + iy * ax3[1] + iz * ax3[2]

     assert, abs(tt - total(t,/double)) / tt lt 1d-3
     assert, total(stamp * ix) / tt lt 1d-3
     assert, total(stamp * iy) / tt lt 1d-3
     assert, total(stamp * iz) / tt lt 1d-3

     assert, total(stamp * p_1) / tt lt 1d-2
     assert, total(stamp * p_2) / tt lt 1d-2
     assert, total(stamp * p_3) / tt lt 1d-2

     uvel = total(t * vel[ci]) / tt
     sig_1 = sqrt(total(stamp * p_1^2) / tt) * len_scale
     sig_2 = sqrt(total(stamp * p_2^2) / tt) * len_scale
     sig_3 = sqrt(total(stamp * p_3^2) / tt) * len_scale

     uvel = total(t * vel[ci]) / tt
     sig_vel = sqrt(  total(t * (vel[ci] - uvel)^2) / tt  ) * vel_scale
     sig_r = (sig_1 * sig_2 * sig_3)^(1D/3D)
     
     data[i].sig_maj = sig_1
     data[i].sig_min = sig_3
     data[i].sig_v = sig_vel
     data[i].sig_r = sig_r
     data[i].flux = tt
     data[i].vol = n_elements(t)
  endfor
  eta = 1.91 ;- correct for concentration of R. see rosolowsky 2008
  g = 6.673d-8
  data.virial = 5 * eta * data.sig_r * data.sig_v^2 / (data.flux * flux2mass * g)

  for i = 0, nst - 1, 1 do begin
     partner = merger_partner(i, (*ptr).clusters, merge = m)
     leaf = leafward_mergers(i, (*ptr).clusters, /parents)
     if partner ne -1 then $
        data[i].shoulder_height = (*ptr).height[i] - (*ptr).height[m]
     if leaf[0] eq -1 then continue
     data[i].vol_left = max(data[leaf].vol, min = lo)
     data[i].vol_right = lo
  endfor

  ptr_free, ptr
  return, data

end
  


