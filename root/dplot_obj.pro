function dplot_obj, ptr, id, norm = norm, _extra = extra
  result = dplot_xy(ptr, id, norm = norm)
  return, obj_new('idlgrplot', result[0,*], result[1,*], _extra = extra)
end
