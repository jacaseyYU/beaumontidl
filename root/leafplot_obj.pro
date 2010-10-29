function leafplot_obj, ptr, _extra = extra
  xy = leafplot_xy(ptr)
  return, obj_new('idlgrplot', xy[0,*], xy[1,*], _extra = extra)
end
