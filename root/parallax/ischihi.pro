pro ischihi

  read_object, '/media/cave/catdir.107/n0000/0351', 4002, m, t
  restore, '/media/cave/catdir.107/n0000/0351.skymodel'

  lo = t.off_measure
  hi = lo+t.nmeasure - 1
  xfloor = skymodel_x[0, lo:hi]
  xfudge = skymodel_x[1, lo:hi]
  xpsf = xpsf[lo:hi]

  yfloor = skymodel_y[0, lo:hi]
  yfudge = skymodel_y[1, lo:hi]
  ypsf = ypsf[lo:hi]

  reduce_object, m, t, xfloor, xpsf, xfudge, $
                 yfloor, ypsf, yfudge, $
                 oflag, flag, mag, pos, pm, par, /bin, /parplot


end              


