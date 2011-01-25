function dg_iso_dual::event, event
  super = self->dg_iso::event(event)
  if (event.id eq self.slider) && self.listener gt 0 then begin
     widget_control, self.listener, send_event = create_struct(event, name='DG_ISO_DUAL_EVENT')
  endif
  return, 1
end
     
function dg_iso_dual::make_polygon, id, _extra = extra
  if min(id) lt 0 then return, obj_new()

  ind = substruct(id, self.ptr)
  if n_elements(ind) lt 5 then return, obj_new()

  ptr = self.ptr

  ;- create a cube
  x = (*ptr).x[ind] & y = (*ptr).y[ind] & z = (*ptr).v[ind]
  ci = (*ptr).cubeindex[ind]

  lo = [min(x, max=mx), min(y, max=my), min(z, max=mz)]
  hi = [mx, my, mz]
  range = hi - lo
  x -= lo[0] & y -= lo[1] & z -= lo[2]

  if min(range) le 1 then return, obj_new()
  cube = fltarr(range[0], range[1], range[2])
  v = cube
  
  cube[x, y, z] = (*ptr).t[ind]
  nanswap, cube, 0

  v[x, y, z] = (*self.vel)[ci]
  ppv = ppp2ppv(cube, v, *self.vgrid)

  widget_control, self.slider, get_value = lev
  hit = where(ppv ne 0, ct)
  if ct eq 0 then return, obj_new()
  hit = ppv[hit]
  lev = (hit[sort(hit)])[0 > (lev * n_elements(hit) - 1)]
  isosurface, ppv, lev, v, c
  print, lev, minmax(ppv)

  if size(v, /n_dim) ne 2 then return, obj_new()
  v[0,*] += lo[0] & v[1,*] += lo[1] 
  o = obj_new('idlgrpolygon', v, poly = c, _extra = extra)
  return, o

end

function dg_iso_dual::init, ptr, vel, vgrid, no_copy = no_copy, _extra = extra
  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, ' obj = obj_new("dg_iso_dual", ptr, vel, vgrid, [/no_copy, _extra = extra]'
     return, 0
  endif

  junk = self->dg_iso::init(ptr, title='PPV isosurfaces', _extra = extra)
  if junk ne 1 then return, 0
  
  self.vel = ptr_new(vel, no_copy = keyword_set(no_copy))
  self.vgrid = ptr_new(vgrid, no_copy = keyword_set(no_copy))
  lo = min((*ptr).t, max = hi, /nan)
  self.slider = cw_fslider(self.base, min = 0., max = 1., value = 0.5)

  return, 1
end

pro dg_iso_dual::cleanup
  ptr_free, self.vel
  ptr_free, self.vgrid
  self->dg_iso::cleanup
end

pro dg_iso_dual__define
  data = {dg_iso_dual, $
          inherits dg_iso, $
          slider:0L, $
          vel : ptr_new(), $
          vgrid : ptr_new() }
end
