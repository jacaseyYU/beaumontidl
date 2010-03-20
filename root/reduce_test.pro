pro driver
  chis = obj_new('stack')
  chis2 = obj_new('stack')
  for i = 000, 1000, 1 do begin
     reduce_test, i, good, chi, chi2
     if not good then continue
     chis->push, chi
     chis2->push, chi2
  endfor
  chi = chis->toArray()
  chi2 = chis2->toArray()

  chi = chi[where(finite(chi))]
  chi2 = chi2[where(finite(chi2))]

  obj_destroy, chis
  obj_destroy, chis2

  h = histogram(chi, loc = loc, min = 0, max = 10, binsize = .1)
  plot, loc, h, psym = 10
  print, total(h)
  h = histogram(chi2, loc = loc, min = 0, max = 10, binsize = .1)
  oplot, loc, h, psym = 10, color = fsc_color('red')
  print, total(h)
end

pro reduce_test, objid, good, chi, chi2
  plot = 0
  good = 0

  if n_elements(objid) eq 0 then objid = 30
  file = '/media/cave/catdir.101/n0000/0237'
  read_object, file, objid, m, t

  if n_elements(m) lt 50 then return
  good = 1


  common test_common, xpsf, skymodel_x, ypsf, skymodel_y
  if n_elements(xpsf) eq 0 then begin
     restore, file+'.skymodel'
  endif

  lo = t.off_measure
  hi = lo + t.nmeasure - 1
  xfloor = skymodel_x[0, lo:hi]
  xfudge = skymodel_x[1, lo:hi]
  yfloor = skymodel_y[0, lo:hi]
  yfudge = skymodel_y[1, lo:hi]
  psfx = xpsf[lo:hi]
  psfy = ypsf[lo:hi]

  ;print, 'floor (median / sigma)'
  ;print, median(xfloor), medabsdev(xfloor, /sigma)
  ;print, median(yfloor), medabsdev(yfloor, /sigma)

  ;print, 'fudge (median / sigma)'
  ;print, median(xfudge), medabsdev(xfudge, /sigma)
  ;print, median(yfudge), medabsdev(yfudge, /sigma)

  ;print, 'psf (median / sigma)'
  ;print, median(psfx), medabsdev(psfx, /sigma)
  ;print, median(psfy), medabsdev(psfy, /sigma)


  ;print, 'Old error bars, no binning'
  ;reduce_object, m, t, $
  ;               xfloor, psfx, xfudge, $
  ;               yfloor, psfy, yfudge, $
  ;               oflag, flag, mag, pos, pm, par, /olderror
  ;print, pos.chisq, pos.ndof, pos.chisq / pos.ndof

  ;print, pm.chisq, pm.ndof, pm.chisq / pm.ndof
  ;print, par.chisq, par.ndof, par.chisq / par.ndof


  ;print, 'Old error bars, binning'
  reduce_object, m, t, $
                 xfloor, psfx, xfudge, $
                 yfloor, psfy, yfudge, $
                 oflag, flag, mag, pos, pm, par, /olderror, /bin
  chi2 = pos.chisq / pos.ndof

 ; print, pos.chisq, pos.ndof, pos.chisq / pos.ndof
  ;print, pm.chisq, pm.ndof, pm.chisq / pm.ndof
  ;print, par.chisq, par.ndof, par.chisq / par.ndof


  ;print, 'new error bars, no binning'
  reduce_object, m, t, $
                 xfloor, psfx, xfudge, $
                 yfloor, psfy, yfudge, $
                 oflag, flag, mag, pos, pm, par, /verbose

  ;print, pos.chisq, pos.ndof, pos.chisq / pos.ndof
  chi = pos.chisq / pos.ndof
  ;print, pm.chisq, pm.ndof, pm.chisq / pm.ndof
  ;print, par.chisq, par.ndof, par.chisq / par.ndof

  ;- how does psf * xfudge * mag_err compare to x_ccd_err?
  if plot then begin
  
     oldmodel = sqrt((m.x_ccd_err * .187 / 100D)^2 + (.0149666)^2)
     newmodel = sqrt(xfloor^2 + (psfx * xfudge * m.mag_err)^2)
     ex = newmodel
     ey = sqrt(yfloor^2 + (psfy * yfudge * m.mag_err)^2)
     
     plot, oldmodel, newmodel, psym = 4 ;, xra = minmax(newmodel), yra = minmax(newmodel)
     oplot, arrgen(0, 1, .01), arrgen(0, 1, .01)
     bad = where(flag ne 0, ct)
     if ct ne 0 then begin
        oplot, oldmodel[bad], newmodel[bad], color = fsc_color('red'), psym = 4
     endif
     
     ploterror, m.d_ra, m.d_dec, ex, ey, psym = 5
     if ct ne 0 then oplot, m[bad].d_ra, m[bad].d_dec, psym = 5, color = fsc_color('red')
     ;ploterror, m.time, m.d_ra, ex * 0, ex, psym = 5
     ;oploterror, m.time, m.d_dec, ey * 0, ey, psym = 5, color = fsc_color('red')
  endif

  ;print, 'new error bars. binning'
  ;reduce_object, m, t, $
  ;               xfloor, psfx, xfudge, $
  ;               yfloor, psfy, yfudge, $
  ;               oflag, flag, mag, pos, pm, par, /bin, /verbose
  ;print, pos.chisq, pos.ndof, pos.chisq / pos.ndof
  ;print, pm.chisq, pm.ndof, pm.chisq / pm.ndof
  ;print, par.chisq, par.ndof, par.chisq / par.ndof

end

