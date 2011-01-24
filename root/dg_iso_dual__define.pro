function dg_iso::make_polygon, id, _extra = extra
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

  ;- trying something new here: 
  ;- isosurfacing on the data produces a cleaner surface
  ;- than working with a binary mask. However, if all id's 
  ;- don't belong to a single structure hierarchy, there is 
  ;- no unique level to isosurface on. We should test for this and 
  ;- correct in the future.
  if min(range) le 1 then return, obj_new()
  cube = fltarr(range[0], range[1], range[2])
  v = cube
  
  cube[(*ptr).x - lo[0], (*ptr).y - lo[1], (*ptr).v - lo[2]] = (*ptr).t
  nanswap, cube, 0

  v[(*ptr).x - lo[0], (*ptr).y - lo[1], (*ptr).v - lo[2]] = (*self.vel)[ci]
  ppv = ppp2ppv(cube, v, (*ptr).vgrid)

  isosurface, ppv, .01 * max(ppv), v, c

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

  junk = self->dg_iso::init(ptr, _extra = extra)
  if junk ne 1 then return, 0
  
  self.vel = ptr_new(vel, no_copy = keyword_set(no_copy))
  self.vgrid = ptr_new(vgrid, no_copy = keyword_set(no_copy))
  return, 1
end

pro dg_iso_dual::cleanup
  ptr_free, self.vel
  ptr_free, vgrid
  self->dg_iso::cleanup
end

pro dg_iso_dual__define
  data = {dg_iso_dual, $
          inherits dg_iso, $
          vel : ptr_new(), $
          vgrid : ptr_new(0 }
end
