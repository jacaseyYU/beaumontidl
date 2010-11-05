pro cw_colorpick, parent

  names = (fsc_color(/names))[0:95]
  
  xsize = 500 & ysize = 500
  nrow = 10 & ncol = 10

  dx = xsize / nro & dy = ysize / ncol
  
  base = widget_base(
