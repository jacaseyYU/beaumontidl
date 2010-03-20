pro read_object, name, obj_id, m, t
  on_error, 2
  if ~file_test(name+'.cpm') then $
     message, 'file not found: '+name+'.cpm'

  t = mrdfits(name + '.cpt', 1, h, range = [obj_id, obj_id], /silent)
  lo = t.off_measure
  hi = lo + t.nmeasure - 1
  m = mrdfits(name+'.cpm', 1, h, range = [lo, hi],/silent)
  return

end
