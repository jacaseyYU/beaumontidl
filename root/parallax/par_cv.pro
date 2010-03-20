pro test
  common parcv, dx, dy, color
  color = 0

  restore, '/media/cave/catdir.98/s0000/4801.good.sav'
  hit = where(par.parallax / sqrt(par.covar[4,4]) lt -4, ct)
  obj = t[hit].obj_id
  device, decomposed = 0
  loadct, 2, /silent
  plot, [0],[0], /nodata, xra = [-.5, 3.5], yra = [-10,3], /xsty, /ysty

  for i = 0, ct - 1, 1 do $
     par_cv, '/media/cave/catdir.98/s0000/4801', obj[i]
end

pro par_cv, file, object

  common parcv, dx, dy, color
  if n_elements(dx) eq 0 then restore, file+'.skymodel'

  read_object, file, object, m, t
  lo = t.off_measure
  hi = t.nmeasure - 1 + lo
  xerr = dx[lo:hi]
  yerr = dy[lo:hi]


  if 0 then begin
  pars = replicate({parfit}, t.nmeasure)
  for i = 0, t.nmeasure - 1, 1 do begin
     if (i eq 0) then begin
        subm = m[1:*]
        subx = xerr[1:*]
        suby = yerr[1:*]
     endif else if (i eq t.nmeasure - 1) then begin
        subm = m[0:t.nmeasure - 2]
        subx = xerr[0:t.nmeasure-2]
        suby = yerr[0:t.nmeasure-2]
     endif else begin
        subm = [m[0:i-1], m[i+1:*]]
        subx = [xerr[0:i-1], xerr[i+1:*]]
        suby = [yerr[0:i-1], yerr[i+1:*]]
     endelse

     reduce_object, subm, t, $
                    subx, suby, ofl, fl, mag, ipos, ipm, ipar
     pars[i] = ipar
  endfor
endif
  
  nrep = 5
  pars = replicate({parfit}, nrep)
  for i = 0, nrep-1, 1 do begin
     ind = findgen((t.nmeasure -1)/ nrep) * nrep + i
     subm = m[ind]
     subx = xerr[ind]
     suby = yerr[ind]
     reduce_object, subm, t, $
                    subx, suby, ofl, fl, mag, ipos, ipm, ipar
     pars[i] = ipar
  endfor
  
   oplot, pars.parallax / sqrt(pars.covar[4,4]), psym = -4, color = color++
   print, minmax(pars.parallax), minmax(pars.parallax / sqrt(pars.covar[4,4]))

end
