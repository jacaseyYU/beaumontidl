pro hip32851_plot
  outfile='/home/beaumont/hip32851'
  read_object, '/media/cave/catdir.98/s0000/4800', 17569, m2, t2
  restore, '/media/cave/catdir.98/s0000/4800.skymodel'
  lo = t2.off_measure
  hi = lo + t2.nmeasure - 1
  psfx = xpsf[lo:hi]
  psfy = ypsf[lo:hi]
  xfloor = skymodel_x[0,lo:hi]
  xfudge = skymodel_x[1,lo:hi]
  yfloor = skymodel_y[0,lo:hi]
  yfudge = skymodel_y[1,lo:hi]
  reduce_object, m2, t2, $
                 xfloor, psfx, xfudge, $
                 yfloor, psfy, yfudge, $
                 a, b, c, pos, pm, par, $
                 /parplot, /verbose, /pmplot, $
                 ps =outfile, $
                 title = 'HIP 32851'
end
