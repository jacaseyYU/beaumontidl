pro dg_iso::set_substruct, index, substruct
  self->dg_client::set_substruct, index, substruct, status
  if ~status then return

  ;- get substruct isosurface
  iso = self->make_polygon(substruct, color = self.colors[*, index], $
                           alpha = self.alpha[index])
  if obj_valid(self.sub_isos[index]) then begin
     self->remove_graphics_atom, self.sub_isos[index]
     obj_destroy, self.sub_isos[index]
  endif
  self.sub_isos[index] = iso
  if obj_valid(iso) then self->add_graphics_atom, iso
  self->request_redraw
end

function dg_iso::make_polygon, id, _extra = extra
  if id lt -1 then return, obj_new()

  ind = substruct(id, self.ptr)
  if n_elements(ind) eq 0 then return, obj_new()

  ptr = self.ptr

  ;- create a cube
  x = (*ptr).x[ind] & y = (*ptr).y[ind] & z = (*ptr).v[ind]
  lo = [min(x, max=mx), min(y, max=my), min(z, max=mz)]
  hi = [mx, my, mz]
  range = hi - lo
  x -= lo[0] & y -= lo[1] & z -= lo[2]
  cube = fltarr(range[0], range[1], range[2])
  cube[x, y, z] = 1
  
  ;-cube to surface
  isosurface, cube, 1, v, c
  v = mesh_smooth(v, c)
  v[0,*] += lo[0] & v[1,*] += lo[1] & v[2,*] += lo[2]
  
  ;- center of cube to origin
  v[0,*] -= self.xcen & v[1,*] -= self.ycen & v[2,*] -= self.zcen

  help, v
  ;- surface to polygon
  o = obj_new('idlgrpolygon', v, poly = c, _extra = extra)
  return, o
end

function dg_iso::init, ptr, color = color, listener = listener, $
                  _extra = extra
  junk = self->dg_client::init(ptr, listener, color = color)
  
  xra = minmax((*ptr).x)
  yra = minmax((*ptr).y)
  zra = minmax((*ptr).v)
  model = obj_new('idlgrmodel')

  self.xcen = mean(xra) & self.ycen = mean(yra) & self.zcen = mean(zra)
  sz = [0, xra[1], yra[1], zra[1]]
  
  zra = [min([xra, yra, zra], max=hi), hi]
  zra += 3*range(zra) * [-1,1]
  zra = reverse(zra)

  ;- lights
  l1 = obj_new('idlgrlight', type = 2, loc = [sz[1], sz[2], 2*sz[3]], $
               color=[255,255,255], inten=.7)
  l2 = obj_new('idlgrlight', type = 0, inten = 0.5, $
               color = [255,255,255])
  l3 = obj_new('idlgrlight', type = 2, loc = [-sz[1], -sz[2], -2*sz[3]], inten=.7)
  ;- axes
  a1 = obj_new('idlgraxis', 0, range=[0,sz[1]]-sz[1]/2., title=obj_new('idlgrtext', 'X'))
  a2 = obj_new('idlgraxis', 1, range=[0,sz[2]]-sz[2]/2., title=obj_new('idlgrtext', 'Y'))
  a3 = obj_new('idlgraxis', 2, range=[0,sz[3]]-sz[3]/2., title=obj_New('idlgrtext', 'Z'))
  
  model->add, l1
  model->add, l2
  model->add, l3
  model->add, a1
  model->add, a2
  model->add, a3
  return, self->interwin::init(model, $
                               xra = xra - mean(xra), yra = yra - mean(yra), zra = zra - mean(zra), $
                               _extra = extra, /rotate, eye = 1.5 * max(zra), /depth_test_disable)
end

pro dg_iso__define
  data = {dg_iso, $
          inherits interwin, $
          inherits dg_client, $
          sub_isos: objarr(8), $
          xcen:0., ycen:0., zcen:0.}
end


pro test_event, event
  widget_control, event.top, get_uvalue = obj
end
pro test
  restore, '~/dendro/ex_ptr_small.sav'
  tlb = widget_base()
  widget_control, tlb, /realize
  di = obj_new('dg_iso', ptr, listen = tlb)
  di->set_substruct, 0, 160
  di->run
  xmanager, 'test', tlb, /no_block
end
  
