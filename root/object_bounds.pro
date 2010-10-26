pro object_bounds, model, xrange, yrange, zrange

  if n_params() eq 0 then begin
     print, 'Calling sequence:'
     print, ' object_bounds, model, xrange, yrange, zrange'
     return
  endif

  if ~obj_isa(model, 'IDLGRMODEL') then $
     message, 'input must be an IDLGrModel object'

  objs = model->get(/all, count = ct)
  if ct eq 0 then return

  i = 0
  while i lt n_elements(objs) do begin
     o = objs[i]
     if obj_isa(o, 'IDLGRMODEL') then begin
        new = o->get(/all, count = ct)
        if ct gt 0 then objs=[objs, new]
     endif
     
     if obj_isa(o, 'IDLGRPLOT') || $
        obj_isa(o, 'IDLGRPOLYGON') then begin
        o->getProperty, xrange = x, yrange = y, zrange = z
        xrange = [xrange[0] < x[0], xrange[1] > x[1]]
        yrange = [yrange[0] < y[0], yrange[1] > y[1]]
        zrange = [zrange[0] < z[0], zrange[1] > z[1]]
     endif
  endwhile
end
